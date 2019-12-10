# Copyright 2018-present Open Networking Foundation
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

# Example: ./callprotoc.py voltha.Event voltha_protos/events.proto .

import subprocess
import sys


def call_protoc(buf, msg_name, proto_file_name, include_dir):
    process = subprocess.Popen(["protoc", "--decode=" + msg_name, proto_file_name, "-I", include_dir], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    process.stdin.write(buf)
    print process.communicate()[0]
    process.stdin.close()


def main():
    if len(sys.argv) < 3:
        print >> sys.stderr, "Syntax: callprotoc.py <message_name> <proto_filename> <include_dir>"
        sys.exit(-1)

    msg_name = sys.argv[1]
    proto_filename = sys.argv[2]
    include_dir = sys.argv[3]

    buf = ""
    in_bytes = sys.stdin.read(1)
    while in_bytes:
        buf = buf + in_bytes
        while "===VOLTHA-DELIM===" in buf:
            (part, buf) = buf.split("===VOLTHA-DELIM===", 1)
            call_protoc(part, msg_name, proto_filename, include_dir)
        in_bytes = sys.stdin.read(1)


if __name__ == "__main__":
    main()
