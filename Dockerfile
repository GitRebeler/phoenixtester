FROM python:3.8-slim-buster
LABEL John Hebeler

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Setting the Time Zone
ENV TZ=CST6CDT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

# Install pip requirements
ADD requirements.txt .
RUN python -m pip install -r requirements.txt

# Install the rest
RUN apt-get -y update && apt-get -y install \
    && apt-get -y install libgssapi-krb5-2 git cron wget kinit supervisor \
    && mkdir -p /etc/supervisord.d && mkdir -p /opt/mda_workflow/logs && mkdir -p /opt/mda_workflow/bin \
    && mkdir -p /opt/mda_workflow/conf && mkdir -p /opt/mda_workflow/src \
    && wget -c https://github.com/lalinsky/python-phoenixdb/archive/refs/tags/v0.7.tar.gz -O - | tar -xz \
    && apt -y install iputils-ping && apt -y install vim

RUN cd python-phoenixdb-0.7 && python setup.py install

COPY . /app
COPY main.py /opt/mda_workflow/src/
COPY phoenix.py /opt/mda_workflow/src/
RUN cp supervisord.conf /etc/

#ENTRYPOINT ["/app/entry.sh"]
ENTRYPOINT [ "/bin/sh","/app/entry.sh" ]