class StaticController < ApplicationController
  def landing
    render layout: 'landing'
  end

  def documentation
    @navigation = :documentation

    @document_path = '/app/views/static/documentation.md'

    # Read document
    document = File.read("#{Rails.root}/#{@document_path}")

    # Parse frontmatter
    @frontmatter = YAML.safe_load(document)

    @document_title = @frontmatter['title']

    @content = MarkdownPipeline.new.call(document)

    @namespace_path = "_documentation/#{@product}"
    @namespace_root = '_documentation'
    @sidenav_root = "#{Rails.root}/_documentation"

    render layout: 'documentation'
  end

  def tools
    @navigation = :tools
    @document_title = 'SDKs & Tools'
    render layout: 'page'
  end

  def community
    @navigation = :community
    @document_title = 'Community'
    @upcoming_events = Event.upcoming
    @past_events_count = Event.past.count
    @sessions = Session.published
    @sessions = Session.all if current_user&.admin?
    render layout: 'page'
  end

  def past_events
    @navigation = :community
    @document_title = 'Community'
    @past_events = Event.past
    render layout: 'page'
  end

  def contribute
    # Read document
    document = File.read("#{Rails.root}/app/views/static/contribute.md")

    # Parse frontmatter
    @frontmatter = YAML.safe_load(document)

    @document_title = @frontmatter['title']

    @content = MarkdownPipeline.new.call(document)

    render layout: 'static'
  end

  def legacy
    # Read document
    document = File.read("#{Rails.root}/app/views/static/legacy.md")

    # Parse frontmatter
    @frontmatter = YAML.safe_load(document)
    @document_title = @frontmatter['title']
    @content = MarkdownPipeline.new.call(document)

    render layout: 'page'
  end

  def robots
    render 'robots.txt'
  end

  def podcast
    # Get URL and split the / to retrieve the landing page name
    yaml_name = request.fullpath.split('/')[1]

    # Load the YAML for that particular page
    @content = YAML.load_file("#{Rails.root}/config/landing_pages/#{yaml_name}.yml")

    render layout: 'landing'
  end

  def migrate
    render layout: 'landing'
  end

  def migrate_details

    page = params[:guide].split('/')[0]

    @namespace_path = "_documentation/#{page}"
    @namespace_root = '_documentation'
    @sidenav_root = "#{Rails.root}/_documentation"
    @skip_feedback = true

    if page == 'sms'
      @active_path = '/messaging/sms/overview'
      @active_title = 'Migrate from Tropo'
      @product = 'SMS'
      @blocks = [
        {
          'title' => 'Send an SMS',
          'content' => 'Flavour text for sending an SMS',
          'nexmo' => '_examples/migrate/tropo/send-an-sms/nexmo',
          'tropo' => '_examples/migrate/tropo/send-an-sms/tropo',
        },
      ]
    end

    if page == 'voice'
      @active_path = '/voice/voice-api/overview'
      @active_title = 'Migrate from Tropo'
      @product = 'Voice'
      @blocks = [
        {
          'title' => 'Make an outbound call',
          'content' => 'Flavour text for making a voice call',
          'nexmo' => '_examples/migrate/tropo/make-an-outbound-call/nexmo',
          'tropo' => '_examples/migrate/tropo/make-an-outbound-call/tropo',
        },
      ]
    end

    @building_blocks = @blocks.map do |block|
      block['nexmo'] = "<h2>Nexmo</h2>
        ```building_blocks
          code_only: true
          source: #{block['nexmo']}
        ```"

      block['tropo'] = "<h2>Tropo</h2>
        ```building_blocks
          code_only: true
          source: #{block['tropo']}
        ```"

      block
    end
    render layout: 'documentation'
  end

  def team
    @team = YAML.load_file("#{Rails.root}/config/team.yml")

    if current_user&.admin?
      @careers = Career.all
    else
      @careers = Career.published
    end

    render layout: 'page'
  end
end
