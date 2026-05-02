# Import Packages

import oci
import uuid
import base64

# Setup basic variables
# Auth Config
CONFIG_PROFILE = "DEFAULT"
config = oci.config.from_file('~/.oci/config', CONFIG_PROFILE)

# Compartment where processor job will be created (required)
COMPARTMENT_ID = "ocid1.compartment.oc1..aaaaaaaajd3p6ew234aulp42g3ns2phr5cbncacwrwwp2sor62dccdys6iiq"  # e.g. "ocid1.compartment.oc1..aaaaaaaae5j73axsja5fnahbn23ilop3ynjkcg77mcvgryddz4pkh2t5ppaq";

def create_processor_job_callback(times_called, response):
    print("Waiting for processor lifecycle state to go into succeeded state:", response.data)

# Setup input location where document being processed is stored.
object_location = oci.ai_document.models.ObjectLocation()
object_location.namespace_name = "idizdwpbvdsb"  # e.g. "axabc9efgh5x"
object_location.bucket_name = "document_demo"  # e.g "docu-bucket"
object_location.object_name = "Invoice.pdf"  # e.g "invoice-white-clover.tif"

aiservicedocument_client = oci.ai_document.AIServiceDocumentClientCompositeOperations(oci.ai_document.AIServiceDocumentClient(config=config))

# Document Key-Value extraction Feature
key_value_extraction_feature = oci.ai_document.models.DocumentKeyValueExtractionFeature()

# Setup the output location where processor job results will be created
output_location = oci.ai_document.models.OutputLocation()
output_location.namespace_name = "idizdwpbvdsb"  # e.g. "axabc9efgh5x"
output_location.bucket_name = "document_demo"
output_location.prefix = "processed"

# Create a processor_job for invoice key_value_extraction feature. 
# Note: If you want to use another key value extraction feature, set document_type to "RECIEPT" "PASSPORT" or "DRIVER_ID". If you have a mix of document types, you can remove document_type
create_processor_job_details_key_value_extraction = oci.ai_document.models.CreateProcessorJobDetails(
                                                    display_name=str(uuid.uuid4()),
                                                    compartment_id=COMPARTMENT_ID,
                                                    input_location=oci.ai_document.models.ObjectStorageLocations(object_locations=[object_location]),
                                                    output_location=output_location,
                                                    processor_config=oci.ai_document.models.GeneralProcessorConfig(features=[key_value_extraction_feature],
                                                                                                                document_type="INVOICE"))

print("Calling create_processor with create_processor_job_details_key_value_extraction:", create_processor_job_details_key_value_extraction)
create_processor_response = aiservicedocument_client.create_processor_job_and_wait_for_state(
    create_processor_job_details=create_processor_job_details_key_value_extraction,
    wait_for_states=[oci.ai_document.models.ProcessorJob.LIFECYCLE_STATE_SUCCEEDED],
    waiter_kwargs={"wait_callback": create_processor_job_callback})

print("processor call succeeded with status: {} and request_id: {}.".format(create_processor_response.status, create_processor_response.request_id))
processor_job: oci.ai_document.models.ProcessorJob = create_processor_response.data
print("create_processor_job_details_key_value_extraction response: ", create_processor_response.data)

print("Getting defaultObject.json from the output_location")
object_storage_client = oci.object_storage.ObjectStorageClient(config=config)
get_object_response = object_storage_client.get_object(namespace_name=output_location.namespace_name,
                                                    bucket_name=output_location.bucket_name,
                                                    object_name="{}/{}/{}_{}/results/{}.json".format(
                                                        output_location.prefix, processor_job.id,
                                                        object_location.namespace_name,
                                                        object_location.bucket_name,
                                                        object_location.object_name))
print(str(get_object_response.data.content.decode()))
