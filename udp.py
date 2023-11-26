import socket

UDP_IP = "0.0.0.0"  # Listen on all available interfaces
UDP_PORT = 8080

BUFFER_SIZE = 1460

def main():
    # Create a UDP socket
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        # Bind the socket to the specified IP address and port
        s.bind((UDP_IP, UDP_PORT))
        print(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")

        while True:
            # Receive data from the ESP32
            data, addr = s.recvfrom(BUFFER_SIZE)

            # Save the received data to a file
            save_to_file(data)

def save_to_file(data):
    # Specify the file name to save the image
    file_name = "received_image.jpg"

    # Append the received data to the file
    with open(file_name, "ab") as file:
        file.write(data)

if __name__ == "__main__":
    main()
