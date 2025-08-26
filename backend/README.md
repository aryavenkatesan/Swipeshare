# Setup
Ensure you are in the `/backend` dir for all of this
Install dependencies:
```bash
pip install -r requirements.txt
```
Add your Firebase service account key:
* Navigate to the Firebase Console
* Go to **Project Settings > Service accounts**
* Click on "Generate a new private key"
* Add the newly downloaded json file to the root of the `/backend/src` dir
* **Rename the key to `serviceAccountKey.json`**

Add secrets:
* Duplicate the `.env.template` file and rename it to `.env`
* Follow the instructions in the template file to populate the fields

Run the dev server:
* Navigate to `/backend/src` in terminal
* Run with `fastapi dev`
* Test by navigating to http://127.0.0.1:8000/docs