### Import Packages
import time
import oci
import json
import re

from oci.ai_vision import AIServiceVisionClient
from oci.ai_vision.models.create_image_job_details import CreateImageJobDetails
from oci.ai_vision.models.image_object_detection_feature import ImageObjectDetectionFeature
from oci.ai_vision.models.input_location import InputLocation
from oci.ai_vision.models.object_list_inline_input_location import ObjectListInlineInputLocation
from oci.ai_vision.models.object_location import ObjectLocation
from oci.ai_vision.models.object_storage_document_details import ObjectStorageDocumentDetails
from oci.ai_vision.models.output_location import OutputLocation
from oci.object_storage import ObjectStorageClient

### Define Variables
namespace_name = "NAMESPACE_HERE"
bucket_name = "BUCKET_NAME_HERE"
compartment_id = "COMPARTMENT_OCID_HERE"
input_prefix = "sample_jpg"
output_prefix = "output"
max_results_per_image = 25

config = oci.config.from_file('~/.oci/config')

ai_vision_client = oci.ai_vision.AIServiceVisionClient(config)

### Get Images from Object Storage Using Object Storage Client
# List Objects in Bucket
object_storage_client = ObjectStorageClient(config)
object_list = object_storage_client.list_objects(
    namespace_name = namespace_name,
    bucket_name = bucket_name,
    prefix = input_prefix
)

# Create List of All Testing Images
image_list = []
for i in object_list.data.objects:
    if i.name.endswith('.jpg'):
        object_location = ObjectLocation()
        object_location.bucket_name = bucket_name
        object_location.namespace_name = namespace_name
        object_location.object_name= i.name
        image_list.append(object_location)

### Vision AI
# Send the Request to Service with Multiple Features
image_object_detection_feature = ImageObjectDetectionFeature()
image_object_detection_feature.max_results = max_results_per_image
features = [image_object_detection_feature]

# Setup Input Location
object_locations1 = image_list
input_location = ObjectListInlineInputLocation()
input_location.object_locations = object_locations1

# Setup Output Location
output_location = OutputLocation()
output_location.namespace_name = namespace_name
output_location.bucket_name = bucket_name
output_location.prefix = output_prefix

# Details Setup
create_image_job_details = CreateImageJobDetails()
create_image_job_details.features = features
create_image_job_details.compartment_id = compartment_id
create_image_job_details.output_location = output_location
create_image_job_details.input_location = input_location

# Send the testing images to Vision service by calling creat_image_job API to get analyze images and it returns json responses
res = ai_vision_client.create_image_job(create_image_job_details=create_image_job_details)

# Final Prefix Variable
final_prefix= output_prefix+"/"+res.data.id+"/"+namespace_name+"_"+bucket_name+"_"+input_prefix+"/"

# Logic to perform the following statistics:
# 1. Count the number ofcars and trees in each image, and total up the counts
# 2. Report the nu,bers of  cars and trees, and the number of images processed

# Wait for images to be processed
print("Wait for images to be analyzed. Timeout after 90 seconds")
job_status = res.data.lifecycle_state
print("Job status: ", res.data.lifecycle_state)
i = 1
while i <= 18:
    res = ai_vision_client.get_image_job(image_job_id=res.data.id)
    if job_status != res.data.lifecycle_state:
        print("Job status: ", res.data.lifecycle_state)
        job_status = res.data.lifecycle_state
    if res.data.lifecycle_state == 'SUCCEEDED' or res.data.lifecycle_state == 'CANCELING' or res.data.lifecycle_state == 'FAILED' or res.data.lifecycle_state == 'CANCELED':
        break
    else:
        time.sleep(5)
        i+= 1

print("\n")

car_count = 0
total_car_count = 0
tree_count = 0
total_tree_count = 0
image_counter = 0
no_match_list = []

# List all JSON responses received by Vision AI
object_storage_client = ObjectStorageClient(config)
object_list = object_storage_client.list_objects(
    namespace_name = namespace_name,
    bucket_name = bucket_name,
    prefix = final_prefix
)

# Count number of cars and number of trees
for i in object_list.data.objects:
    car_count = 0
    tree_count = 0

    image_counter=image_counter+1
    body=object_storage_client.get_object(namespace_name, bucket_name, object_name=i.name)
    dict_test= json.loads(body.data.content.decode('utf-8'))
    for j in dict_test['imageObjects']:
        if (j['name'] == 'Car' or j['name'] == 'Vehicle' or j['name'] == 'Truck' or j['name'] == 'Van'):
            car_count = car_count + 1
        if (j['name'] == 'Tree'):
            tree_count = tree_count + 1

    total_car_count = total_car_count + car_count
    total_tree_count = total_tree_count + tree_count

print ("Number of Cars found in images:", total_car_count,"\n")
print ("Number of Trees found in images:", total_tree_count, "\n")
print ("Number of images processed:", image_counter, "\n")     

for i in no_match_list:
    i=re.sub(final_prefix,'',i)
    i=re.sub('.json','',i)
    print(i)
