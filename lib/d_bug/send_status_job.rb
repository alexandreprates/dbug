module Sidekiq
  class SendStatusJob

    include Sidekiq::Worker
    sidekiq_options retry: 5, dead: true

    def perform(subscription_item_id, status)
      subscription_item = Billing::SubscriptionItem.find(subscription_item_id)

      external_code = subscription_item.external_code
      # TODO: REVER ESSE FIX - RAILS CONVERTE IDS STRINGS PARA INTEIRO CASO COMECEM COM NÚMERO
      return if external_code != external_code.to_i.to_s

      private_token = subscription_item.company.private_token
      sale_group = subscription_item.sale_item.group
      SaasInternalExternal.build(private_token, sale_group.base_uri, sale_group.external_url)
                          .send_status(external_code, status)
      subscription_item.create_history_status
    end

  end
end
