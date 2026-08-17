# Jobber API Ruby client

A client for the Jobber GraphQL API. It needs the standard library and two files of Active
Support, to tell a field Jobber answered empty from one it never answered at all.

## Available methods

### Credentials

Generate the URL for Jobber users to authorize the app:

```ruby
url = Jbr.oauth_url_for redirect_uri:, state:
url # => 'https://api.getjobber.com/api/oauth/authorize?state=...&redirect_uri=...'
```

Create credentials with a code and a redirect URI:

```ruby
oauth = Jbr.create_oauth code:, redirect_uri:
```

Initialize with existing credentials:

```ruby
oauth = Jbr.oauth_for access_token:, refresh_token:, expires_at:, account_id:
```

Where several processes hold copies of the same credentials — a queue of workers, each
building its own — hand over a `store:` as well, and only one of them will ever spend the
refresh token:

```ruby
oauth = Jbr.oauth_for account_id:, invalid_at:, store: credentials
```

The store is anything answering two methods. `exclusively` takes whatever lock the app keeps
over those credentials and yields them *as they are right now*, read inside that lock; `write`
records the ones Jobber handed back:

```ruby
def exclusively = with_lock { yield oauth_params }   # Active Record, in an app that has it

def write(oauth) = update oauth: oauth
```

An expired access token is then refreshed once. Every other holder takes the lock, finds a
token that is no longer the one it tried, adopts it, and asks Jobber nothing — where without a
store each of them would spend a refresh token the first has already spent, and Jobber would
call every one of those a dead grant.

`exclusively` has to be exclusive against every **process** sharing the credentials, not just
every thread: a `Mutex` satisfies this interface and fixes nothing on a fleet of workers.

Access OAuth attributes:

```ruby
oauth.access_token # => 'eyJhbGciOiJIUzI1NiJ'
oauth.refresh_token # => 'ea02775958c5fca28d'
oauth.expires_at # => 2026-05-22 14:32:53
oauth.account_id # => 'Z2lkOi8vSm9iYmV'
```

Revoke credentials:

```ruby
oauth.delete
```

Credentials go bad only when Jobber says so of the grant itself — `The provided refresh token
is not valid.` — which sets `invalid_at` and answers queries with nothing. Anything else that
goes wrong raises `Jbr::Error` instead: a 500, a rate limit, and the 401 Jobber answers an app
whose own client id and secret are wrong, which is every account's grant at once rather than
this one's:

```ruby
oauth.invalid_at # => 2026-08-13 11:02:41, or nil while the credentials are good
oauth.query '{ ok }' # => {} once they are refused, raises Jbr::Error where Jobber had trouble
```

### Requests

Create a Jobber request, finding or creating a Client with a matching phone number:

```ruby
request = oauth.requests.create first_name: 'Jane', last_name: 'Doe', phone: '5553335555',
  email: 'jane@example.com', title: 'New Plumber Lead', instructions: 'Needs new faucet'
request.id # => 'Z2lkOi8vSm9iYmVyL'
request.client_id # => 'MwMTU0Mg'
```

### Quotes

Fetch a quote from Jobber:

```ruby
quote = oauth.quotes.find 'Z2lkOi8vS'
quote.id # => 'Z2lkOi8vS'
quote.request_id # => 'Z2lkOi8vSm9iYmVyL'
```

### Jobs

Fetch a job from Jobber by the ID it is filed under:

```ruby
job = oauth.jobs.find 'Njc5MTk5'
job.id # => 'Z2lkOi8vS'
job.quote_id # => 'Z2lkOi8vS'
job.scheduled_at # => 2026-05-14 23:02:52
job.completed_at # => 2026-05-18 11:36:13
```

Or walk the account's jobs, oldest first. Jobber is asked for a page at a time, and only
once the page before it runs out, so `first` costs one request where `to_a` costs as many
as the account has pages. A walk paces itself, so a long one is never refused: see
[Rate limits](#rate-limits).

```ruby
jobs = oauth.jobs # => an Enumerable of every job, nothing fetched yet
oauth.jobs.past # => an Enumerator of the ones dated before now
oauth.jobs.upcoming # => an Enumerator of the ones dated from now on

job = jobs.first
job.name # => 'Furnace tune-up', or the job's ID where nobody titled it. Never nil or empty
job.title # => 'Furnace tune-up'
job.instructions # => 'Ring the doorbell twice'
job.status # => 'requires_invoicing'
job.total # => 260.0
job.quote_total # => 240.0
job.created_at # => 2026-05-10 09:15:00
```

### Line items

What the work actually was, where the title is only what somebody called it. Asked for the
same way as anything nested, since a page costs what it carries:

```ruby
job = oauth.jobs.includes(:line_items).find 'Njc5MTk5'

job.summary # => '3 Bathroom Faucet Installation and 2 Change Toilet Valve', the lines as a
            #    sentence of how many of what. Falls back to #name where there are none

job.line_items # => an Array of the lines the job is made of
line = job.line_items.first
line.quantity # => 3, whole where Jobber's own Float has nothing after the point, and 3.5
              #    where it has: `3 Faucets`, or `3.5 Hours` for what was really billed
line.name # => 'Bathroom Faucet Installation'
line.to_s # => '3 Bathroom Faucet Installation', how many of what, and the name alone where
          #    Jobber holds no quantity for the line
```

Every line Jobber holds is in the list, up to twenty of them, in the order it holds them and
whatever each is quantified at. One it holds no quantity for reads as its name alone. Ask for
nothing and nothing arrives, so `oauth.jobs.first.line_items` is empty where the query never
named them.

### Invoices

Fetch a non-draft invoice from Jobber:

```ruby
invoice = oauth.invoices.find 'MjU3ODA0'
invoice.id # => 'MjU3ODA0'
invoice.job_id # => 'Z2lkOi8vS'
invoice.total # => '40.30'
invoice.issued_at # => 2026-05-22 12:12:53
invoice.completed_at # => 2026-05-22 14:32:53
```

### Visits

Walk the account's visits, oldest first, the same way as its jobs:

```ruby
visits = oauth.visits # => an Enumerable of every visit, nothing fetched yet
oauth.visits.upcoming # => an Enumerator of the ones dated from now on
oauth.visits.past # => an Enumerator of the ones dated before now

visit = visits.first
visit.id # => 'Z2lkOi8vS'
visit.name # => 'Furnace tune-up', or the visit's ID where nobody titled it. Never nil or empty
visit.title # => 'Furnace tune-up'
visit.job_id # => 'Z2lkOi8vS'
visit.starts_at # => 2026-08-09 14:00:00
visit.ends_at # => 2026-08-09 16:00:00
visit.all_day? # => false
visit.client_confirmed? # => true
```

### Clients and properties

Jobber prices a query by what it brings back, so nothing nested comes back unless it is
asked for. Chain `includes` the way Active Record does, on visits or on jobs:

```ruby
visit = oauth.visits.includes(:client, property: :client).upcoming.first

visit.client.name # => 'Jane', or the business's name where the client is a business.
                  # Never an empty string: a blank first name falls through to the company
visit.client.first_name # => 'Jane'
visit.client.last_name # => 'Doe'
visit.client.company_name # => nil
visit.client.email # => 'jane@example.com'
visit.client.phone # => '5553335555', the reachable North American number, or nil

visit.property.id # => 'Z2lkOi8vS'
visit.property.street # => '1 Main St'
visit.property.city # => 'Raleigh'
visit.property.zip # => '27601'
visit.property.address # => { street: '1 Main St', city: 'Raleigh', state: 'NC',
                       #      zip: '27601', latitude: 35.77, longitude: -78.63 }
visit.property.client.name # => whoever the place sits on the file of
```

Ask for nothing and nothing arrives: `oauth.visits.first.client.name` is nil where the
query never named a client.

### Rate limits

Jobber holds an app to two limits at once: 2,500 requests every five minutes, and a bucket of
query cost that drains as it is asked and refills at a rate it reports. This gem does nothing
about either — it never sleeps, and it never asks a second time. What it does is say exactly
what happened, so the caller can decide:

```
Throttled (cost 1885, 1254 of 10000 available, restoring 500/s)
```

That arrives as a `Jbr::Error`. 631 points short of a query the bucket holds five times over,
which a second would have refilled — worth asking again. A cost above `maximumAvailable` is
worth nothing but a smaller query. Either way the decision belongs to whoever called: from a
background job, letting it fail so the queue brings it back is better than a worker asleep
holding a transaction open.

Every connection the gem asks for is bounded, to keep a query on the affordable side of that:
twenty lines to a job, and twenty jobs or visits to a page.

### Events

Parse the payload of a Jobber event webhook:

```ruby
event = Jbr::Event.new data: { webHookEvent: { topic: 'JOB_CREATE', appId: 'app-1',
  accountId: 'account-1', itemId: 'job-1', occurredAt: '2026-05-22T15:46:33Z' } }
event.account_id # => 'account-1'
event.item_id # => 'job-1'
```

## Available mocks

Use these methods to mock request to Jobber when testing an app:

### Credentials

Mock successfully creating and revoking credentials:

```ruby
Jbr.mock
```

Mock an error when creating credentials:

```ruby
Jbr.mock.oauth_error = 'Flow rejected'
```

Mock a custom redirect URL:

```ruby
Jbr.mock.oauth_url = 'https://example.com'
```

### Requests

Mock successfully creating a request:

```ruby
Jbr.mock.request = { id: 'request-01', client_id: 'client-01' }
```

### Quotes

Mock successfully fetching a quote:

```ruby
Jbr.mock.quote = { id: 'quote-01', request_id: 'request-01' }
```

### Jobs

Mock successfully fetching a job by ID:

```ruby
Jbr.mock.job = { id: 'job-01', quote_id: 'quote-01', scheduled_at: Date.tomorrow.noon }
```

Mock the jobs the account has. The mock dates nothing it was handed: what answers to
`past` and to `upcoming` is whatever `scheduled_at` the app gave each one:

```ruby
Jbr.mock.jobs = [ { id: 'job-01', title: 'Furnace tune-up', status: 'archived',
  total: 260.0, quote_total: 240.0, created_at: Date.yesterday.noon,
  scheduled_at: Date.yesterday.noon, completed_at: Date.today.noon,
  property: { id: 'property-01', street: '1 Main St',
    client: { id: 'client-01', company_name: 'Acme Property Management' } } } ]
```

Mock the lines a job is made of, under the job that is made of them:

```ruby
Jbr.mock.jobs = [ { id: 'job-01', line_items: [
  { quantity: 3.0, name: 'Bathroom Faucet Installation',
    description: 'Professional installation of a new bathroom faucet' },
  { quantity: 2.0, name: 'Change Toilet Valve' } ] } ]

oauth.jobs.past.first.summary
# => '3 Bathroom Faucet Installation and 2 Change Toilet Valve'
```

### Visits

Mock the visits the account has:

```ruby
Jbr.mock.visits = [ { id: 'visit-01', title: 'Furnace tune-up', job_id: 'job-01',
  property: { id: 'property-01', street: '1 Main St',
    client: { id: 'client-01', first_name: 'Jane' } },
  client: { id: 'client-01', first_name: 'Jane' },
  starts_at: Date.tomorrow.noon, ends_at: Date.tomorrow.end_of_day,
  all_day: false, client_confirmed: true } ]
```

### Invoices

Mock successfully fetching an invoice:

```ruby
Jbr.mock.invoice = { id: 'invoice-01', job_id: 'job-01', total: 19.99, issued_at: Date.yesterday.noon }
```
