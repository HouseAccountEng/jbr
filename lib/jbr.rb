require 'json'
require 'net/http'

# The vocabulary every record here answers in, and the Active Support it brings along. One
# more file of it: an address is sent without the fields a caller left blank.
require 'company'
require 'active_support/core_ext/enumerable'

require 'graphql/error'
require 'graphql/unauthorized'
require 'graphql/throttled'
require 'graphql/client'

require 'jbr/version'
require 'jbr/error'
require 'jbr/refused'
require 'jbr/retriable'
require 'jbr/token'
require 'jbr/refreshing'
require 'jbr/querying'
require 'jbr/authorizing'
require 'jbr/mock'

# Phone before Customer, and Location before Customers: what each asks Jobber for is built as
# it loads. Every record before the collection that reads it, for the same reason.
require 'jbr/phone'
require 'jbr/customer'
require 'jbr/location'
require 'jbr/line'
require 'jbr/job'
require 'jbr/visit'
require 'jbr/quote'
require 'jbr/invoice'
require 'jbr/lead'

require 'jbr/collection'
require 'jbr/includable'
require 'jbr/listable'
require 'jbr/jobs'
require 'jbr/visits'
require 'jbr/quotes'
require 'jbr/invoices'
require 'jbr/customers'
require 'jbr/locations'
require 'jbr/leads'
require 'jbr/account'

require 'jbr/mock/jobs'
require 'jbr/mock/visits'
require 'jbr/mock/quotes'
require 'jbr/mock/invoices'
require 'jbr/mock/leads'
require 'jbr/mock/account'

require 'jbr/event'
