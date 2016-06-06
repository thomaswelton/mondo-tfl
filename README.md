# Mondo TFL

Pulls in travel information from TFL, matches journeys to the transaction, generates a JPG Receipt and attaches it to the Mondo transaction.

---

![travel info in Mondo](https://cloud.githubusercontent.com/assets/395/15808595/e3bbfd0a-2b72-11e6-917e-560a387c15de.PNG)

---

## Requirements

Requires a `.env` file with the following details in Rails root.

```
MONDO_CLIENT_ID=
MONDO_SECRET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-1
AWS_S3_BUCKET=
```
