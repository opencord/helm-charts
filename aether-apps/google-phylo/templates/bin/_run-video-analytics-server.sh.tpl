#!/bin/bash
#
# Copyright 2020-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

/google/video_analytics_server_main \
        --mediapipe_graph_path=/google/demo_graph.pbtxt \
        --person_detection_tf_saved_model_dir=/google/saved_model/ \
        --camera_scene_geometry_path=/google/camera_scene_geometry.pbtxt \
        --grpc_port=50051 \
        --mq_address=localhost:5672 \
        --mediapipe_detection_topic_name=phylo.mediapipe_detection \
        --person_detection_topic_name=phylo.person_detection \
        --bbox_decoded_video_frame_topic_name=phylo.bbox_decoded_video_frame \
        --publish_to_mq=true \
        --publish_to_log=true
