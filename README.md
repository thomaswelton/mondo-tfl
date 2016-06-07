# Mondo TFL

Pulls in travel information from TFL, matches journeys to the transaction, generates a JPG Receipt and attaches it to the Mondo transaction.

---

![travel info in Mondo](https://cloud.githubusercontent.com/assets/395/15869952/772f6df0-2ce6-11e6-9dc9-42f2f9714b63.PNG)

---

## Todo

- only selects the first contactless card in TFL. So if you've been using contactless cards on TFL before and have multiple contactless cards registered @ contactless.tfl.gov.uk then it probably won't select the right card. Ideally Mondo-TFL would let you select which card to scrape.

## Getting Started

1. Login to https://developers.getmondo.co.uk/.
2. Explore API endpoints in the Playground.
3. Create a New OAuth Client in Clients.
4. Set the Redirect URL to `http://localhost:3000/auth/mondo/callback`, you may set `Confidentiality` to confidential as we are creating a server based client, as apposed to something like an iPad application.
5. Make note of the `Client ID` and the `Client Secret`.
6. Download or Clone Mondo-TFL from https://github.com/jameshill/mondo-tfl
7. Create a `.env` file in your application root containing your ID & Secret it should look **something** like this, obviously this is just a dummy example, use *your* creditials.

```
MONDO_CLIENT_ID=
MONDO_SECRET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-1
AWS_S3_BUCKET=
```

Once you have done the standard database creation and migration you should be all ready to explore

```
rake db:create
rake db:migrate
rails server
open http://localhost:3000
```

You'll then need to login, which will then take you through the Mondo OAuth implementation.
Once you've logged in you now need to provide you Transport for London `username` & `password`.

With credentials for both TFL & Mondo stored the following rake tasks can be run:

```
rake mt:pull_journeys
```

`pull_journeys` pulls journey information from TFL and stores it in the local journey table.

```
rake mt:attach_receipts
```

`attach_receipts` sequentially runs through the journey table and the outstanding Mondo transactions and matches them. It then generates a jouney log JPG and uploads to Amazon S3. The final step is registering the S3 file with Mondo.

```
rake mondo_tfl:clear_receipts
```

`clear_receipts` cycles through each user in the local database and deregisters the first file attached to each TFL transaction.
