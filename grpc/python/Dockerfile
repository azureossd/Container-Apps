FROM python:3.15.0a8

RUN pip install grpcio grpcio-reflection

ADD greeter_server_with_reflection.py \
    helloworld_pb2.py \
    helloworld_pb2_grpc.py \
    /root/

WORKDIR /root

EXPOSE 50051

CMD python greeter_server_with_reflection.py