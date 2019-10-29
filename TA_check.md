### 第1回1.5節
```
sudo apt-get update
sudo apt-get install python-wstool python-catkin-tools
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
source /opt/ros/melodic/setup.bash
git clone https://github.com/jsk-enshu/robot-programming
wstool init .
wstool merge robot-programming/.rosinstall.melodic
wstool update
rosdep update
rosdep install --from-paths . --ignore-src -y -r
cd ..
catkin build
```


### 第1回3.1節
Turtlebotのudevの設定（PCごとに一度やればよい）．
```
rosrun kobuki_ftdi create_udev_rules
```
タートルボットのUSBケーブルをPCに接続し
```
ls /dev/kobuki
```
があることを確認．

```
echo "export TURTLEBOT_3D_SENSOR=kinect" >> ~/.bashrc
# >> は追記の意味であるが, > とすると上書きしてしまうので注意すること!!!
```


### 第1回3.2節
```
roslaunch turtlebot_bringup minimal.launch
```
を実行し，
```
rostopic echo /mobile_base/events/bumper
```
で，タートルボットのバンパを押して値が変わるか確認．
また，
```
rostopic pub -1 /mobile_base/commands/led1 `rostopic type /mobile_base/commands/led1` 3
```
として，タートルボットのLEDが赤色になるか確認．



### 第1回5.3節

ジョイスティックをPCに接続し，
```
sudo bash
rosrun ps3joy sixpair
```
を実行．
ジョイスティックのUSBケーブルをPCから抜いて，
```
rosrun ps3joy ps3joy.py
```
で、ペアリングボタン（中央のプレステマークのボタン）を押し，
```
Connection activated
```
と表示されることを確認．
```
ls /dev/input/js0
```
があることを確認．

minimal.launchは上げたままで，
```
roslaunch dxl_armed_turtlebot turtlebot_joystick_teleop.launch
```
を実行して，
L1を押しながら左ジョイスティックを操縦し，前進後退・旋回ができることを確認．


### 第2回2.1節
minimal.launchは上げたままで，
以下のコマンドで，センサ値を取得しgo-velocityできるか確認．
```
roscd turtleboteus/euslisp
roseus turtlebot-interface.l
(turtlebot-init)
(send *ri* :state :bumper-vector) ;; バンパセンサ
(send *ri* :state :button-vector) ;; 背面ボタン
(send *ri* :state :wheel-drop-vector) ;; 落輪センサ
(send *ri* :publish-sound :error) ;; エラー音
(send *ri* :go-velocity 0.1 0 0) ;; 少し前に移動
(send *ri* :go-velocity -0.1 0 0) ;; 少し後ろに移動
(send *ri* :go-velocity 0 0 10.0) ;; 少し左回りに移動
(send *ri* :go-velocity 0 0 -10.0) ;; 少し右回りに移動
```


### 第2回3.2節
Turtlebotのudevの設定（PCごとに一度やればよい）．
```
rosrun dynamixel_7dof_arm create_udev_rules
```
DXHUBのUSBケーブルをPCに接続し
```
ls /dev/dynamixel_arm
```
があることを確認．

以下を実行し，
```
rosrun dynamixel_7dof_arm scan_ids.py -p /dev/dynamixel_arm
```
1から7すべてのIDについて，"respond to a ping"と表示されることを確認．


### 第2回3.3節
```
roslaunch dynamixel_7dof_arm dynamixel_7dof_arm_bringup.launch
```
を実行し，
```
roscd dxl_armed_turtlebot/euslisp
roseus dxl-armed-turtlebot-interface.l
(dxl-armed-turtlebot-init) ;; アーム+台車ロボットの *ri* と *dxl-armed-turtlebot* を生成
(send *dxl-armed-turtlebot* :reset-pose) ;; 関節角度を :reset-pose にセット
(send *irtviewer* :draw-objects) ;; 描画
(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 4000)
```
を実行して，実機がIrtviewerと同じ姿勢になるかを確認．
（組み付けが間違えていることがあるのでちゃんと確認する．）


```
(dotimes (i 6)
  (setq angle-vector (float-vector 0 0 0 0 0 0))
  (send *ri* :angle-vector angle-vector 3000)
  (send *ri* :wait-interpolation)
  (setf (elt angle-vector i) 60) ;; i 番目の関節のみ 60deg
  (send *ri* :angle-vector angle-vector 3000)
  (send *ri* :wait-interpolation)
  (read-line) ;; Enter キーを押すのを待つ
  )
```
を実行して，根本から6つの軸が順番に動くか確認．
これも2回ぐらい確認する．


```
(send *ri* :servo-off-all)
```
を実行して，全軸（グリッパ含む）のサーボがOFFになること，
```
(send *ri* :servo-on-all)
```
を実行して，全軸（グリッパ含む）のサーボがONになることを確認．

```
(send *ri* :move-gripper 50)
```
でグリッパが開くこと．
```
(send *ri* :start-grasp)
```
でグリッパが閉じ，
```
(send *ri* :stop-grasp)
```
で開くことを確認．


### 第2回4.1節
KinectのUSBケーブルをPCに接続し（USBハブを経由せず，PCに直接指す），
```
roslaunch turtlebot_bringup 3dsensor.launch
```
と
```
roslaunch turtlebot_rviz_launchers view_robot.launch
```
を実行する．
RvizでRGB画像("Image")と色付き点群("Registered PointCloud")が描画されることを確認する．


### 第3回2.1節
3dsensor.launchとview_robot.launchは上げたまま，
```
roslaunch dxl_armed_turtlebot checkerboard_detector_5x4.launch
```
と
```
roscd dxl_armed_turtlebot/euslisp
roseus display-checkerboard.l
```
を実行して，チェッカーボードが認識されていることを確認．

チェッカーボードのプログラムを落とし，
```
roslaunch dxl_armed_turtlebot hsi_color_filter.launch
```
を実行して，
Rvizで，BoundingBoxArrayを追加して，"/camera/depth_registered/boxes"のトピックを追加し，
赤色物体のバウンディングボックスが描画されることを確認．


### 第1回4.3節，第2回4.3節
これまでのlaunchをすべて落とす．

車載PCと遠隔PCを準備する．

車載PCで，
```
rossetlocal
rossetip
```
遠隔PCで，
```
rossetmaster [車載PCのIPアドレス]
rossetip
```
をする．

車載PCを，
Turtlebot，Kinect，アームと接続し，
```
roslaunch dxl_armed_turtlebot dxl_armed_turtlebot_bringup.launch
```
を上げる．

遠隔PCで，
- `(send *ri* :state :bumper-vector)`でセンサ値が取得できるか
- `(send *ri* :go-velocity)`をして台車が動くか
- `(send *ri* :angle-vector)`をしてアームが動くか
- Rvizで画像やポイントクラウドが表示できるか

を確認する．
