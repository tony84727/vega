(local targets ["minecraft:wheat" "minecraft:carrots" "minecraft:potatoes"])
(local fuel "minecraft:coal")

(fn log-location! []
  (when false 
    (print (.. "location: " (textutils.serialize current-location)))))

(fn log-orientation! []
  (when false
    (print (.. "orientation: " (textutils.serialize orientation)))))

(fn get-seed [crop]
  (match crop
    "minecraft:wheat" "minecraft:wheat_seeds"
    "minecraft:potatoes" "minecraft:potato"
    "minecraft:carrots" "minecraft:carrot"
    crop))

(global current-location [0 0])
(global orientation [1 0])
(global station-location nil)

(fn rotate-orientation [v deg]
  (let [deg (if (< deg 0)
                (+ deg 360)
                deg)
        cos
        (fn [deg]
          (match deg
            0 1
            90 0
            180 -1
            270 0) )
        sin
        (fn [deg]
          (match deg
            0 0
            90 1
            180 0
            270 -1))]
    [(- (* (cos deg) (. v 1)) (* (sin deg) (. v 2)))
     (+ (* (sin deg) (. v 1)) (* (cos deg) (. v 2)))]))

(fn vec-add [a b]
  [(+ (. a 1) (. b 1)) (+ (. a 2) (. b 2))])

(fn vec-sub [a b]
  [(- (. a 1) (. b 1)) (- (. a 2) (. b 2))])

(fn turn-right! []
  (when (turtle.turnRight)
    (global orientation (rotate-orientation orientation -90))
    (log-orientation!)
    true))

(fn turn-left! []
  (when (turtle.turnLeft)
    (global orientation (rotate-orientation orientation 90))
    (log-orientation!)
    true))

(fn forward! []
  (when (turtle.forward)
    (global current-location (vec-add current-location orientation))
    (log-location!)
    true))

(fn back! []
  (when (turtle.back)
    (global current-location (vec-sub current-location orientation))
    (log-location!)
    true))

(fn must! [f]
  (while true
    (when (f)
        (lua "return true"))))

(fn dot [a b]
  (+ (* (. a 1) (. b 1)) (* (. a 2) (. b 2))))

(fn dot3 [a b]
  (+ (* (. a 1) (. b 1))
     (* (. a 2) (. b 2))
     (* (. a 3) (. b 3))))

(fn len [a]
  (math.pow (+ (math.pow (. a 1) 2) (math.pow (. a 2) 2)) 0.5))

(fn acos [value]
  (match value
    0 90
    1 0
    -1 180))

(fn cross [a b]
  [(- (* (. a 2) (. b 3)) (* (. a 3) (. b 2)))
   (- (* (. a 1) (. b 3)) (* (. a 3) (. b 1)))
   (- (* (. a 1) (. b 2)) (* (. a 2) (. b 1)))])

(fn angle [a b]
  (let [crossv (cross [(. a 1) (. a 2) 0] [(. b 1) (. b 2) 0])
        signv (dot3 crossv [0 0 1])
        neg (< signv 0)
        angle (acos (/ (dot a b) (* (len a) (len b))))]
    (if neg (- angle) angle)))

(fn abs [x]
  (if (< x 0) (- x) x))

(fn rotate-to-angle! [target]
  (let [deg (angle orientation target)]
    (when (~= deg 0)
      (let [turn! (if (> deg 0)
                     turn-left!
                     turn-right!)
            steps (/ (abs deg) 90)]
        (for [_ 1 steps]
          (turn!))))))

(fn move-to! [to]
  (let [diff (vec-sub to current-location)]
    (when (~= (len diff) 0)
      (let [x (. diff 1)
            y (. diff 2)]
        (rotate-to-angle! (if (< x 0) [-1 0] [1 0]))
        (for [_ 1 (abs x)] (must! (fn [] (forward!))))
        (rotate-to-angle! (if (< y 0) [0 -1] [0 1]))
        (for [_ 1 (abs y)] (must! (fn [] (forward!))))))))

(fn harvest? [inspect-data]
  (each [_ t (ipairs targets)]
    (if (and (= inspect-data.name t)
             (= inspect-data.state.age 7))
        (lua "return true")))
  false)

(fn in-range? [inspect-data]
  (or (not inspect-data) (~= inspect-data.name "minecraft:cobblestone")))

(fn select! [target]
  (for [i 1 16]
    (turtle.select i)
    (let [detail (turtle.getItemDetail)]
      (if (and (~= detail nil) (= detail.name target))
          (lua "return true"))))
  false)

(fn harvest! [target]
  (turtle.digDown)
  (select! (get-seed target))
  (turtle.placeDown))

(fn switch-row!
  [reverse]
  (let [turn (if reverse turn-left! turn-right!)]
    (turn)
    (forward!)
    (turn)
    (forward!)))

(global switch-row-direction false)

(fn enough-storage? []
  (var empty 0)
  (for [i 1 16]
    (when (= 0 (turtle.getItemCount i))
      (set empty (+ empty 1))))
  (> empty 2))

(fn enough-fuel? []
  (> (turtle.getFuelLevel) 40))

(fn enough-fuel-storage? []
  (var coal 0)
  (for [i 1 16]
    (let [detail 
          (turtle.getItemDetail i)]
      (when detail
        (if (= fuel detail.name)
            (set coal (+ coal (turtle.getItemCount i)))))))
  (> coal 16))

(fn refuel! []
  (for [i 1 16]
    (let [detail (turtle.getItemDetail i)]
      (when (and detail (= detail.name fuel))
        (turtle.select i)
        (turtle.refuel 1)
        (lua "return true"))))
  false)

(fn dump! []
  (move-to! [0 0])
  (global switch-row-direction false)
  (rotate-to-angle! [1 0])
  (for [i 2 16]
          (turtle.select i)
          (turtle.dropDown)))

(while true
  (let [(_ inspect-data) (turtle.inspectDown)]
    (if
     (not (enough-storage?))
     (do
       (print "dump")
       (dump!))
     (= inspect-data.name "minecraft:oak_planks")
     (do
       (print "rtb")
       (dump!)
       (os.sleep 300))
     (not (enough-fuel-storage?))
     (do
       (print "getting fuel")
       (move-to! [0 0])
       (global switch-row-direction false)
       (rotate-to-angle! [1 0])
       (turtle.select 1)
       (turtle.suckUp (turtle.getItemSpace 1)))
     (not (enough-fuel?))
     (do (refuel!)
         (print "refuel"))
     (= inspect-data.name "minecraft:cobblestone")
     (do
       (switch-row! switch-row-direction)
       (global switch-row-direction (not switch-row-direction)))
     (harvest? inspect-data)
     (harvest! inspect-data.name)
     (forward!))))
