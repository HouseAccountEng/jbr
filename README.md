# Jobber API Ruby client

## Available methods

Initialize the authentication with a code:

```ruby
oauth = Jbr::OAuth.create code: code, redirect_uri: jobber_callback_url
```

Access OAuth attributes:

```
oauth.access_token # => 'eyJhbGciOiJIUzI1NiJ'
oauth.refresh_token # => 'ea02775958c5fca28d'
oauth.expires_at # => 2026-05-22 14:32:53
oauth.account_id # => 'Z2lkOi8vSm9iYmV'
````

Create a Jobber request, finding or creating a Client with a matching phone number:

```ruby
request = oauth.requests.create first_name: 'Jane', last_name: 'Doe', phone: '5553335555',
  email: 'jane@example.com', title: 'New Plumber Lead', instructions: 'Needs new faucet'
request.id # => 'Z2lkOi8vSm9iYmVyL'
request.client_id # => 'MwMTU0Mg'
```

Fetches a quote from Jobber:

```ruby
quote = oauth.quotes.find 'Z2lkOi8vS'
quote.id # => 'Z2lkOi8vS'
quote.request_id # => 'Z2lkOi8vSm9iYmVyL'
```

Fetches a job from Jobber:

```ruby
job = oauth.jobs.find 'Njc5MTk5'
job.id # => 'Z2lkOi8vS'
job.quote_id # => 'Z2lkOi8vS'
job.scheduled_at # => 2026-05-14 23:02:52
job.completed_at # => 2026-05-18 11:36:13
```

Fetches a non-draft invoice from Jobber:

```ruby
invoice = oauth.invoices.find 'MjU3ODA0'
invoice.id # => 'MjU3ODA0'
invoice.job_id # => 'Z2lkOi8vS'
invoice.total # => '40.30'
invoice.issued_at # => 2026-05-22 12:12:53
invoice.completed_at # => 2026-05-22 14:32:53
```


Revoke authentication:

```ruby
oauth.delete
```

