#!/usr/bin/env roseus

(ros::roseus-add-msgs "kobuki_msgs")

(ros::roseus "kadai1_3_2_sound")

(ros::advertise "/mobile_base/commands/sound" kobuki_msgs::Sound 1)

(setq msg (instance kobuki_msgs::Sound :init))
(send msg :value 2)

(ros::ros-info "ready to publish !!!")
(ros::rate 1)
(while (ros::ok)
  (ros::ros-info "publish msg [value: ~A]" (send msg :value))
  (ros::publish "/mobile_base/commands/sound" msg)
  (ros::sleep)
  )
