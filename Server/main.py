# import socket
#
# UDP_IP = "0.0.0.0"  # Listen on all available interfaces
# UDP_PORT = 8080
#
# BUFFER_SIZE = 1460
#
# def main():
#     # Create a UDP socket
#     with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
#         # Bind the socket to the specified IP address and port
#         s.bind((UDP_IP, UDP_PORT))
#         print(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")
#
#         while True:
#             # Receive data from the ESP32
#             data, addr = s.recvfrom(BUFFER_SIZE)
#
#             # Save the received data to a file
#             save_to_file(data)
#
# def save_to_file(data):
#     # Specify the file name to save the image
#     file_name = "received_image_1.jpg"
#
#     # Append the received data to the file
#     with open(file_name, "ab") as file:
#         file.write(data)
#
# if __name__ == "__main__":
#     main()

from flask import Flask, render_template, Response
import socket
import cv2
import numpy as np

app = Flask(__name__)

UDP_IP = "0.0.0.0"  # Listen on all available interfaces
UDP_PORT = 8080
BUFFER_SIZE = 1460

def receive_image():
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.bind((UDP_IP, UDP_PORT))
        print(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")

        img_buffer = b''

        while True:
            data, _ = s.recvfrom(BUFFER_SIZE)

            if data.startswith(b'\xff\xd8'):
                img_buffer = b''

            img_buffer += data

            if data.endswith(b'\xff\xd9'):
                display_image(np.frombuffer(img_buffer, dtype=np.uint8))

def display_image(img_data):
    img_array = cv2.imdecode(img_data, cv2.IMREAD_COLOR)

    cv2.imshow("Received Image", img_array)
    cv2.waitKey(1)

@app.route('/')
def index():
    return render_template('index_received.html')

if __name__ == '__main__':
    import threading
    receiver_thread = threading.Thread(target=receive_image, daemon=True)
    receiver_thread.start()

    app.run(debug=True, host='0.0.0.0', port=5000)