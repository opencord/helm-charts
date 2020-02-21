[application]
enable-perf-measurement=1
perf-measurement-interval-sec=5

[tiled-display]
enable={{ .Values.config.deepstream.display.enabled }}
rows=1
columns=1
width=900
height=500
gpu-id=0
nvbuf-memory-type=4

[source0]
enable=1
#Type - 1=CameraV4L2 2=URI 3=MultiURI 4=RTSP, 5=CSI
type=2
uri={{ .Values.config.deepstream.source }}
num-sources=1
#drop-frame-interval=5
gpu-id=0
cudadec-memtype=0

[source1]
enable=0
#Type - 1=CameraV4L2 2=URI 3=MultiURI 4=RTSP, 5=CSI
type=2
uri=file:/root/deepstream_sdk_v4.0.2_jetson/samples/streams/sample_1080p_h265.mp4
num-sources=1
gpu-id=0
cudadec-memtype=0

[sink0]
enable=1
#Type - 1=FakeSink 2=EglSink 3=File 4=RTSPStreaming 5=Overlay
type=5
sync=0
display-id=0
offset-x=100
offset-y=0
width=900
height=500
overlay-id=1
source-id=0

[sink1]
enable=1
#Type - 1=FakeSink 2=EglSink 3=File 4=UDPSink 5=nvoverlaysink 6=MsgConvBroker
type=6
msg-conv-config=/configs/msg_config.txt
msg-conv-payload-type=1
msg-broker-proto-lib=/opt/nvidia/deepstream/deepstream-4.0/lib/libnvds_amqp_proto.so
msg-broker-config=/configs/amqp_config.txt

[osd]
enable=1
border-width=1
text-size=0
text-color=1;1;1;1;
text-bg-color=0.3;0.3;0.3;0
font=Serif
show-clock=1
clock-x-offset=10
clock-y-offset=10
clock-text-size=12
clock-color=0;0;0;.8

[streammux]
live-source=1
batch-size=1
batched-push-timeout=40000
width=1280
height=720

[primary-gie]
enable=1
batch-size=1
bbox-border-color0=1;0;0;1
bbox-border-color1=0;1;1;1
bbox-border-color2=0;0;1;1
bbox-border-color3=0;1;0;1
interval=0
gie-unique-id=1
config-file=/configs/infer_config.txt

[tracker]
enable=1
tracker-width=480
tracker-height=272
ll-lib-file=/opt/nvidia/deepstream/deepstream-4.0/lib/libnvds_nvdcf.so
ll-config-file=/configs/tracker_config.yml
gpu-id=0
enable-batch-process=1

