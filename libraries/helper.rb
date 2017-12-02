module Certbot
  module Helper
    def live_path(domain)
      ::File.join(node['le-certbot']['live_path'], domain)
    end

    def cert_path(domain)
      ::File.join(live_path(domain), 'cert.pem')
    end

    def chain_path(domain)
      ::File.join(live_path(domain), 'chain.pem')
    end

    def fullchain_path(domain)
      ::File.join(live_path(domain), 'fullchain.pem')
    end

    def key_path(domain)
      ::File.join(live_path(domain), 'privkey.pem')
    end

    def webroot_path
      node['le-certbot']['webroot']
    end

    def well_known_path
      ::File.join(webroot_path, '.well-known')
    end

    def renew_hook
      ::File.join(node['le-certbot']['renew_scripts_root'], 'renew.sh')
    end

    def renew_scripts_path
      ::File.join(node['le-certbot']['renew_scripts_root'], 'scripts')
    end

    def renew_script_path(name)
      ::File.join(node['le-certbot']['renew_scripts_root'], 'scripts', name)
    end

    def certbot_executable
      node['le-certbot']['executable_path']
    end

    def certbot_command
      "#{certbot_executable} certonly --non-interactive"
    end

    def create_cert_command
      cmd = [certbot_command]
      cmd.push("--domain #{new_resource.domain}")
      cmd.push("-webroot -w #{webroot_path}")

      renew = case new_resource.renew_policy
              when :force then '--renew-by-default'
              when :keep then '--keep-until-expiring'
              end

      cmd.push(renew)
      cmd.push(test_arg)
      cmd.push("--rsa-key-size #{node['le-certbot']['rsa_key_size']}")

      cmd.join(' ')
    end

    def test_arg
      '--test-cert' if new_resource.test
    end

    def add_certificate(domain)
      node.normal['le-certbot']['certificates'][domain] = {
        key: key_path(domain),
        cert: cert_path(domain),
        chain: chain_path(domain),
        fullchain: fullchain_path(domain),
      }
    end

    def remove_certificate(domain)
      node.normal['le-certbot']['certificates'].delete(domain)
    end
  end
end
