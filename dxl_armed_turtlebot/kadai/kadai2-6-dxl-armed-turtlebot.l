#!/usr/bin/env roseus

(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(load "package://roseus/test/joy.l")

(ros::roseus "kadai2_6_dxl_armed_turtlebot")

(dxl-armed-turtlebot-init)
(init-ps3joy)


(ros::ros-info "send initial pose.")
(send *dxl-armed-turtlebot* :reset-pose)
(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 3000)
(send *ri* :wait-interpolation)

(ros::ros-info "start !!!")
(ros::rate 10)
(setq prev-r1-button 0)
(do-until-key
 ;; 台車を動かす
 ;; PS3コントローラで、L1を押しながら左のジョイスティックで速度指令
 ;; バンパセンサが反応していたら、自動でバックする。
 (setq bumper-vector (send *ri* :state :bumper-vector))
 (cond ((= (norm bumper-vector) 0)
	(cond ((= (send *joy* :l1-button) 1)
	       (setq x-velocity (* 0.1 (send *joy* :ljoy-fb)))
	       (setq theta-velocity (* 30.0 (send *joy* :ljoy-lr)))
	       (ros::ros-info "base velocity: (~A, ~A)" x-velocity theta-velocity)
	       (send *ri* :go-velocity x-velocity 0 theta-velocity)
	       )
	      (t
	       (send *ri* :go-velocity 0 0 0)
	       ))
	)
       (t
	(send *ri* :go-velocity -0.05 0 0)
	(unix::usleep (* 2000 1000))
	))
 ;; アームを動かす
 ;; PS3コントローラで、R1を押しながら右のジョイスティックで前後左右、上下ボタンで上下に
 ;; ビューア上のロボットモデルが動く。R1を離したときに、ロボットモデルの姿勢が実機へ送られる。
 (setq r1-button (send *joy* :r1-button))
 (when (= r1-button 1)
   (setq x-velocity (* 10 (send *joy* :rjoy-fb)))
   (setq y-velocity (* 10 (send *joy* :rjoy-lr)))
   (setq z-velocity 0.0)
   (when (= (send *joy* :up-button) 1)
     (setq z-velocity (+ z-velocity 10)))
   (when (= (send *joy* :down-button) 1)
     (setq z-velocity (- z-velocity 10)))
   (ros::ros-info "arm velocity: (~A, ~A, ~A)" x-velocity y-velocity z-velocity)
   (send *dxl-armed-turtlebot* :arm :move-end-pos
	 (float-vector x-velocity y-velocity z-velocity) :world :rotation-axis nil)
   (send *irtviewer* :draw-objects)
   )
 (when (and (= prev-r1-button 1) (= r1-button 0))
   (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000))
 (setq prev-r1-button r1-button)
 (x::window-main-one)
 (ros::sleep)
 (ros::spin-once)
 )
