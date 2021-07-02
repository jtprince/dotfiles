# invoke:
#     dotenv ipython -i $HOME/bin/init_firebase_rtdb_dev.py"

import firebase_admin
from firebase_admin import db

firebase_admin.initialize_app(
    options={"databaseURL": "https://owletcare-dev.firebaseio.com/"}
)
