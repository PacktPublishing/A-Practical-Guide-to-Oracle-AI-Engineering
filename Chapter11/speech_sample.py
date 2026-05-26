import oci
 
#Source the OCI config file
config = oci.config.from_file()
 
#Set the Varialbles
inputfile="Science_Laws.mp3"
compartmentid="COMPARTMENTZ_OCID_HERE"
bucket="BUCKET_HERE"
namespace="NAME_SPACE_HERE"

#Define the job to transcribe the mps to text
def transcribe(inputfile,compartmentid,bucket,namespace):
    ai_speech_client = oci.ai_speech.AIServiceSpeechClient(config)
    create_transcription_job_response = ai_speech_client.create_transcription_job(
            create_transcription_job_details=oci.ai_speech.models.CreateTranscriptionJobDetails(
                compartment_id=compartmentid,
                input_location=oci.ai_speech.models.ObjectListInlineInputLocation(
                    location_type="OBJECT_LIST_INLINE_INPUT_LOCATION",
                    object_locations=[oci.ai_speech.models.ObjectLocation(
                        namespace_name=namespace,
                        bucket_name=bucket,
                        object_names=[inputfile])]),
                output_location=oci.ai_speech.models.OutputLocation(
                    namespace_name=namespace,
                    bucket_name=bucket)))
 
#transcribe(inputfile="Science_Laws.mp3",compartmentid="ocid1.compartment.oc1..aaaaaaaajd3p6ew234aulp42g3ns2phr5cbncacwrwwp2sor62dccdys6iiq",bucket="Speech_Demo",namespace="idizdwpbvdsb")


#Run the job, output will be in the bucket
transcribe(inputfile,compartmentid,bucket,namespace)


