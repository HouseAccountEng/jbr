require 'json'
require 'net/http'

# Only the three Active Support files whose methods are used, rather than the whole of it:
# Jobber answers a field it holds nothing for with an empty string as readily as with null,
# and a caller who validates presence needs those to arrive as the same nothing. The third is
# for the sentence a job's lines read as.
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array/conversions'

require 'graphql/error'
require 'graphql/unauthorized'
require 'graphql/client'

require 'jbr/mock'

require 'jbr/url'
require 'jbr/error'
require 'jbr/refused'
require 'jbr/token'
require 'jbr/refreshing'
# Phone before Cliental, and Cliental before the records that include it: what each asks
# Jobber for about a client is built as they load.
require 'jbr/phone'
require 'jbr/cliental'
require 'jbr/named'
require 'jbr/resource'
require 'jbr/request'
require 'jbr/oauth'

require 'jbr/account'
# Property comes before Client and Visit: their queries read its fields as they load.
require 'jbr/property'
require 'jbr/properted'
require 'jbr/includable'
# LineItem before Itemized, and both before Job: the lines a job is made of are asked for
# by a constant the include reads as it loads.
require 'jbr/line_item'
require 'jbr/itemized'
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
require 'jbr/mock/line_item'
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
