#set FLASK_APP=humanflask.py
#set FLASK_ENV=development
#flask run --host=192.168.0.109


from importlib.resources import Resource
from keras.models import load_model
from flask import Flask, request, jsonify
import base64
import numpy as np
import io
from tensorflow.keras.utils import img_to_array

import time
from tensorflow.keras.utils import save_img
import tensorflow as tf

from PIL import Image
from flask_restful import Resource, Api, reqparse

app = Flask(__name__)
api = Api(app)

model = load_model('test.h5')
print('* Model loaded')

def prepare_img(image, target):
    if image.mode != "RGB":
        image = image.convert('RGB')

    image = image.resize(target)
    image = img_to_array(image)

    image = (image - 127.5) / 127.5
    image = np.expand_dims(image, axis = 0)

    return image



class Predict(Resource):
    def post(self):
        jason_data = request.get_json()
        img_data = jason_data['Image']

        image = base64.b64decode(str(img_data))

        img = Image.open(io.BytesIO(image))

        prepared_image = prepare_img(img, target = (256, 256))

        preds = model.predict(prepared_image)

        outputfile = 'output.png'
        savepath = './output/'

        output = tf.reshape(preds, [256, 256, 3])    

        output = (output + 1) / 2
        save_img(savepath + outputfile, img_to_array(output))

        imageNew = Image.open(savepath + outputfile)
        imageNew = imageNew.resize((50, 50))
        imageNew.save(savepath +"new_"+outputfile) 

        with open(savepath +"new_"+outputfile, 'rb') as image_file:
            encoded_string = base64.b64encode(image_file.read())
        
        outputData = {
            'Image': str(encoded_string)
        }

        return outputData

api.add_resource(Predict, '/predict')

if __name__ == '__main__':
    app.run(debug=True)