module Jbr
  # The jobs on a Jobber account, oldest first, walked a page at a time.
  class Jobs < Resource
    include Enumerable, Includable

    # What a job answers with wherever one is read, before anything it was asked to bring
    # back with it.
    FIELDS = 'id title instructions jobStatus total createdAt startAt completedAt ' \
             'quote { id amounts { total } }'

    # Every job on the account, past and future alike. Nothing is read until the walk starts,
    # and a page is read only once the one before it runs out.
    def each(&) = walk.each(&)

    # @return [Enumerator<Job>] the jobs scheduled from now on.
    def upcoming = walk from_now

    # @return [Enumerator<Job>] the jobs that started before now.
    def past = walk until_now

    # Shadows Enumerable#find on purpose, the way Active Record does: a job is reached by the
    # ID Jobber files it under, not by asking every job on the account whether it is the one.
    # @param id [String] the Jobber ID of the job.
    # @return [Job, nil] nil when Jobber has no job under that ID.
    def find(id)
      node = @oauth.query(one, variables: { id: id })['job']
      Job.new node: node if node
    end

  private

    # Twenty a page, not forty and not a hundred: Jobber prices a query by its page size, and
    # what an includes brings back is charged for on top of every row of it — so a page of jobs
    # carrying their lines, their property and its client priced past what a bucket holds. Half
    # the page costs half the query and loses nothing, since a walk simply reads more pages.
    def page
      <<~GRAPHQL
        query($after: String, $filter: JobFilterAttributes) {
          jobs(first: 20, after: $after, filter: $filter) {
            nodes { #{FIELDS} #{selections} }
            pageInfo { hasNextPage endCursor }
          }
        }
      GRAPHQL
    end

    def one
      <<~GRAPHQL
        query($id: EncodedId!) {
          job(id: $id) { #{FIELDS} #{selections} }
        }
      GRAPHQL
    end

    def field = 'jobs'

    def item(node) = Job.new node: node
  end
end
