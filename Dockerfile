FROM python:3.8-alpine

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py /app

ENTRYPOINT ["python"]

CMD ["app.py"]

