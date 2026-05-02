
import oci

# Please fill out all paramaters
config_path = "~/.oci/config"
# Place the text you want yo analyze here

text_string="Glass blowing as art in the USA is a thriving, niche art field with slow job growth projection. While facing competitive, often self-employed, conditions, the sector is supported by a growing global art glass market. Key hubs include Seattle,WA , Ashville, NC and Corning, NY. The job market for glass blowers is expected to grow slowley between 2022 and 2032. Despite growth, it is often considered a niche career with high competition in the arts and crafts sector. It also faces an extremely long ammount of time to be able to craft even the most basic itmes like cups and bowls by hand.  A significant portion of glass blowers are self-employed work as independent artists.  Modern studios are integrating digital tools (3D printing, CAD) for precision, and there is a high demand for custom, artistic lighting and decor.  Famous American Glass Blowers include  Dale Chihuly, a pioneer who revolutionized the field, bringing large-scale glass sculpture into the mainstream.  Marvin Lipofsky, a crucial figure in the 1960s Studio Glass Movement.  David Patchen, known for intricate, colorful murrine work and a recipient of scholarships from Pilchuck Glass School.  Joe Peters, a top name in functional glass art (pipes/functional items).  David Schwarzi,renowned for technical mastery over a 25-year career.  Key Museums include the  Corning Museum of Glass (NY) and the Perry Glass Center in Norfolk, VA."


#
# Normal deffinitions 
#
def createLanguageClient(config_path):


    config = oci.config.from_file(
        config_path, "DEFAULT")
    return oci.ai_language.AIServiceLanguageClient(config)

#Set the Language to English
def createTextDocument(key_, data, language_code_="en"):


    return oci.ai_language.models.TextDocument(
        key=key_,
        text=data,
        language_code=language_code_
    )



#
# Ri=uns against mutplie types of analysis
#

def SentimentAnalysis(AI_client, text_document):


    try:
        # Run sentiment analysis on text_document
        detect_language_sentiments_response = AI_client.batch_detect_language_sentiments(
            batch_detect_language_sentiments_details=oci.ai_language.models.BatchDetectLanguageSentimentsDetails(documents=[text_document])
        )
        return detect_language_sentiments_response.data

    # Print service error for debugging
    except Exception as e:
        print(e)
    return


def KeyPhraseExtraction(AI_client, text_document):


    try:
        keyphrase_extraction = AI_client.batch_detect_language_key_phrases(
            batch_detect_language_key_phrases_details=oci.ai_language.models.BatchDetectLanguageKeyPhrasesDetails(documents=[text_document])
        )
        return keyphrase_extraction.data
    except Exception as e:
        print(e)


def NamedEntityExtraction(AI_client, text_document):

    try:
        language_entities = AI_client.batch_detect_language_entities(
            batch_detect_language_entities_details=oci.ai_language.models.BatchDetectLanguageEntitiesDetails(documents=[text_document])
        )

        return language_entities.data

    # Print service error for debugging
    except Exception as e:
        print(e)
    return


def TextClassification(AI_client, text_document):

    try:
        # Run text classification on text_document
        text_classification = AI_client.batch_detect_language_text_classification(
            batch_detect_language_text_classification_details=oci.ai_language.models.BatchDetectLanguageTextClassificationDetails(
                documents=[text_document]
            )
        )
        # return the data
        return text_classification.data

    # Print any API errors
    except Exception as e:
        print(e)
    return



def printDivider():
    # Helper function to print a divider between analysis'
    for i in range(60):
        print("*", end=""),
    print("\n")


def printAllResponses(sentiment_response, key_phrase_response, named_entity_response, text_classification_response):
    print("Sentiment Analysis on text:")
    for i in range(0, len(sentiment_response.documents)):
        for j in range(0, len(sentiment_response.documents[i].aspects)):
            print("\tText: ", sentiment_response.documents[i].aspects[j].text)
            print("\tOverall sentiment: ", sentiment_response.documents[i].aspects[j].sentiment)
            print("\tLength: ", sentiment_response.documents[i].aspects[j].length)
            print("\tOffset: ", sentiment_response.documents[i].aspects[j].offset)

    printDivider()
    print("Key phrase extraction on text:")

    for i in range(len(key_phrase_response.documents)):
        for j in range(len(key_phrase_response.documents[i].key_phrases)):
            print("\tphrase: ", key_phrase_response.documents[i].key_phrases[j].text)
            print("\tscore: ", key_phrase_response.documents[i].key_phrases[j].score)

    printDivider()
    print("Named entity extraction on text:")

    for i in range(len(named_entity_response.documents)):
        for j in range(len(named_entity_response.documents[i].entities)):
            print("\tText: ", named_entity_response.documents[i].entities[j].text)
            print("\tType: ", named_entity_response.documents[i].entities[j].type)
            print("\tSub_Type: ", named_entity_response.documents[i].entities[j].sub_type)
            print("\tLength: ", named_entity_response.documents[i].entities[j].length)
            print("\tOffset: ", named_entity_response.documents[i].entities[j].offset)

    printDivider()
    print("Text classification analysis on text:")
    for i in range(len(text_classification_response.documents)):
        for j in range(len(text_classification_response.documents[i].text_classification)):
            print("\tLabel: ", text_classification_response.documents[i].text_classification[j].label)
            print("\tScore: ", text_classification_response.documents[i].text_classification[j].score)


def runModel(data, config_path="~/.oci/config", text_model_key="Example", language_code="en"):

    # Create language client and text document to be analyzed, up to 100 can be analyzed at the same time.
    language_client = createLanguageClient(config_path)
    text_document = createTextDocument(key_=text_model_key, language_code_="en", data=data)

    # Grab all responses by the AI client
    sentiment_response = SentimentAnalysis(language_client, text_document)
    key_phrase_response = KeyPhraseExtraction(language_client, text_document)
    named_entity_response = NamedEntityExtraction(language_client, text_document)
    text_classification_response = TextClassification(language_client, text_document)


    printAllResponses(sentiment_response, key_phrase_response, named_entity_response, text_classification_response)


# Run example model
runModel(text_string, config_path, text_model_key="example", language_code="en")
