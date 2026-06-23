FROM base:latest AS gorm-drivers

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /root/
# RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git &&\
#     cd ./Livox-SDK2/ &&\
#     mkdir build && cd build &&\
#     cmake .. && make -j &&\
#     sudo make install
#
# RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.zshrc
#
