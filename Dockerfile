FROM ubuntu

RUN  apt-get update

RUN apt-get install tree

CMD ["sh", "-c", "echo hello Priyata"]
