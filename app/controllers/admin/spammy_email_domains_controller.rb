module Admin
  class SpammyEmailDomainsController < BaseController
    before_action :administrators_only, except: :index

    def index
      @spammy_email_domains = SpammyEmailDomain.order(:domain)
    end

    def new
      @spammy_email_domain = SpammyEmailDomain.new
    end

    def edit
      @spammy_email_domain = SpammyEmailDomain.find(params[:id])
      render :new
    end

    def create
      @spammy_email_domain = SpammyEmailDomain.new(spammy_email_domain_params)
      if @spammy_email_domain.save
        redirect_to admin_spammy_email_domains_path
      else
        render :new
      end
    end

    def update
      @spammy_email_domain = SpammyEmailDomain.find(params[:id])
      @spammy_email_domain.assign_attributes(spammy_email_domain_params)
      if @spammy_email_domain.save
        redirect_to admin_spammy_email_domains_path
      else
        render :new
      end
    end

    def destroy
      @spammy_email_domain = SpammyEmailDomain.find(params[:id])
      @spammy_email_domain.destroy!
      # rubocop:disable Rails/I18nLocaleTexts
      redirect_to admin_spammy_email_domains_path, notice: 'Spammy email domain deleted'
      # rubocop:enable Rails/I18nLocaleTexts
    end

    private

    def spammy_email_domain_params
      params.expect(spammy_email_domain: [:domain, :block_type])
    end
  end
end
