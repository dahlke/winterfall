FROM python:3.6
COPY . /web
WORKDIR /web
RUN pip install -r conf/pip_reqs.txt
CMD ["python", "main.py"]