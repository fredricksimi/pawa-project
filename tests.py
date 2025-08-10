import unittest
import json

from app import app

# Setting up our testcase
class ContentAnalyzerTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    # Testing for a successful implementation, with the text input provided along with the correct key
    def test_successful_analysis(self):
        data = {"text": "Harry Potter, the boy who lived"}
        response = self.app.post("/analyze", data=json.dumps(data), content_type="application/json")

        self.assertEqual(response.status_code, 200)
        expected_result = {
            "character_count": 31,
            "original_text": "Harry Potter, the boy who lived",
            "word_count": 6            
        }

    # Test if the input provided is not in a JSON format
    def test_no_json_data(self):
        response = self.app.post("/analyze", data="This is a string, not JSON")
        self.assertEqual(response.status_code, 400)
        expected_result = {"Error": "No data inrequest body!"}
        self.assertEqual(json.loads(response.data), expected_result)

    # Test if the input provided is empty
    def test_empty_text(self):
        data = {"text":""}
        response = self.app.post("/analyze", data=json.dumps(data), content_type="application/json")
        self.assertEqual(response.status_code, 400)
        expected_result = {"Error": "Kindly provide input text to be analyzed!"}
        self.assertEqual(json.loads(response.data), expected_result)

    # Test if the input provided has used another key other than 'text'
    def test_missing_text_key(self):
        """
        Test case for a POST request where the "text" key is missing.
        """
        data = {"some_other_key": "some value"}
        response = self.app.post("/analyze", data=json.dumps(data), content_type="application/json")

        self.assertEqual(response.status_code, 400)
        expected_result = {"Error": "Provide the input with 'text' as the key, and the input as the value"}


if __name__ == '__main__':
    unittest.main()