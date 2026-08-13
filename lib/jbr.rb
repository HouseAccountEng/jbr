require 'json'
require 'net/http'

require 'graphql/error'
require 'graphql/unauthorized'
require 'graphql/client'

require 'jbr/mock'

require 'jbr/url'
require 'jbr/error'
# Phone before Cliental, and Cliental before the records that include it: what each asks
# Jobber for about a client is built as they load.
require 'jbr/phone'
require 'jbr/cliental'
require 'jbr/resource'
require 'jbr/request'
require 'jbr/oauth'

require 'jbr/account'
# Property comes before Client and Visit: their queries read its fields as they load.
require 'jbr/property'
require 'jbr/properted'
require 'jbr/includable'
require 'jbr/client'
require 'jbr/invoice'
require 'jbr/job'
require 'jbr/jobs'
require 'jbr/quote'
require 'jbr/visit'
require 'jbr/visits'

require 'jbr/mock/oauth'
require 'jbr/mock/client'
require 'jbr/mock/property'
require 'jbr/mock/quote'
require 'jbr/mock/job'
require 'jbr/mock/jobs'
require 'jbr/mock/invoice'
require 'jbr/mock/request'
require 'jbr/mock/account'
require 'jbr/mock/url'
require 'jbr/mock/visit'
require 'jbr/mock/visits'

require 'jbr/mocking'

require 'jbr/event'
