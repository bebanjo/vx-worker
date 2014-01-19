require 'vx/common/amqp'

Vx::Common::AMQP.setup(Vx::Worker.logger, url: Vx::Worker.config.amqp_url)
