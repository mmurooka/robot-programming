#!/usr/bin/env roseus

(load "package://turtleboteus/euslisp/turtlebot-interface")

(ros::roseus "kadai1_4_robot_interface")

(defun button-cb
    (msg)
  (setq button (send msg :button))
  (setq state (send msg :state))
  (ros::ros-info "subscribe msg [button: ~A  state: ~A]" button state)
  )

(turtlebot-init)



(ros::ros-info "start !!!")

(ros::rate 100)
(do-until-key
 (setq bumper-vector (send *ri* :state :bumper-vector))
 (cond ((= (norm bumper-vector) 0)
	(send *ri* :go-velocity 0.1 0 0)
	)
       (t
	(send *ri* :go-velocity -0.1 0 0)
	(unix::usleep (* 500 1000))
	(send *ri* :go-velocity 0 0 30)
	(unix::usleep (* 500 1000))
	))
 (setq button-vector (send *ri* :state :button-vector))
 (when (= (elt button-vector 0) 1)
   (send *ri* :go-velocity 0 0 0)
   (send *ri* :publish-sound :error)
   (unix::usleep (* 3000 1000))
   )
 (ros::sleep)
 )

