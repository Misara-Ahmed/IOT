import socket
import cv2
import numpy as np

UDP_IP = "0.0.0.0"  # Listen on all available interfaces
#UDP_PORT = 8080
UDP_PORT = 65002
BUFFER_SIZE = 1460

def receive_image():
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.bind((UDP_IP, UDP_PORT))
        print(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")

        img_buffer = b''

        while True:
            data, _ = s.recvfrom(BUFFER_SIZE)

            print(type(img_buffer))

            if data.startswith(b'\xff\xd8'):
                img_buffer = b''

            img_buffer += data

            if data.endswith(b'\xff\xd9'):
                #print(img_buffer)
                display_image(np.frombuffer(img_buffer, dtype=np.uint8))

def display_image(img_data):
    img_array = cv2.imdecode(img_data, cv2.IMREAD_COLOR)
    print(img_array)

    TARGET_WIDTH = 400
    TARGET_HEIGHT = 600

    # Resize the frame
    resized_frame = cv2.resize(img_array, (TARGET_WIDTH, TARGET_HEIGHT))

    cv2.imshow("Received Image", resized_frame)
    #cv2.imshow("Received Image", img_array)
    cv2.waitKey(1)

while(True):
    receive_image()