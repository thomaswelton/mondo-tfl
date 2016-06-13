# Mondo TFL

This integration pulls in travel information from TFL, matches journeys to the transaction, generates a JPG Receipt and attaches it to the Mondo transaction.

This is purely a Proof of Concept prototype. It can only be used by developers who have registered at https://developers.getmondo.co.uk

In order to run this integration, as outlined below you'll need a Mondo Client Auth, it also uses AWS S3, so you'll need an AWS credentials.

---

![travel info in Mondo](https://cloud.githubusercontent.com/assets/395/15885854/bdc720d0-2d51-11e6-8124-b6516f5fc6e3.jpg)

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
ATTR_SECRET_KEY=
```

Once you have done the standard database creation and migration you should be all ready to explore

```
rake db:create
rake db:migrate
rails server
open http://localhost:3000
```

1. Click *Login with Mondo*
2. Once you're redirected back to MondoTFL you will need to provide your `username` & `password` for Transport for London.
3. Click *Go!*, this will then query TFL and get your contactless cards.
4. Select the card from the list which matches your Mondo card.

With credentials for both TFL & Mondo stored and your Mondo card selected we can now run the following:

```
rake mt:pull_journeys
```

`pull_journeys` pulls journey information from TFL and stores it in the local journey table.

```
rake mt:attach_receipts
```

`attach_receipts` sequentially runs through the journey table and the outstanding Mondo transactions and matches them. It then generates a jouney log JPG and uploads to Amazon S3. The final step is registering the S3 file with Mondo.

```
rake mt:clear_receipts
```

`clear_receipts` cycles through each user in the local database and deregisters the first file attached to each TFL transaction.

```
rake mt:refresh_user_tokens
```

`refresh_user_tokens` cycles through each user in the local database and refreshes their OAUTH `token`, `refresh_token` & `expires_at`


```
rake mt:pull_and_attach
```
`pull_and_attach` executes the following in sequence, `refresh_user_tokens`, `pull_journeys`, 'attach_receipts`
