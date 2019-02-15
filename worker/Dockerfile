FROM python:3.6
COPY . /worker
WORKDIR /worker
RUN pip install -r conf/pip_reqs.txt
CMD ["python", "snowfall.py"]