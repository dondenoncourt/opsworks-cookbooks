action :berks_install do
  directory Opsworks::InstanceAgent::Environment.berkshelf_cookbooks_path do
    action :delete
    recursive true

    only_if do
      node['opsworks_berkshelf']['version'].to_i >= 3
    end
  end

  ruby_block 'Install the cookbooks specified in the Berksfile and their dependencies' do
    block do
      Chef::Log.info OpsWorks::ShellOut.shellout(
        berks_install_command,
        :cwd => Opsworks::InstanceAgent::Environment.site_cookbooks_path,
        :environment  => {
          "BERKSHELF_PATH" => Opsworks::InstanceAgent::Environment.berkshelf_cache_path
        }
      )
    end

    only_if do
      OpsWorks::Bershelf.berkshelf_installed? && OpsWorks::Bershelf.berksfile_available?
    end
  end
end

def berks_install_command
  options = if node['opsworks_berkshelf']['version'].to_i >= 3
    "vendor #{Opsworks::InstanceAgent::Environment.berkshelf_cookbooks_path}"
  else
    "install --path #{Opsworks::InstanceAgent::Environment.berkshelf_cookbooks_path}"
  end

  "#{OpsWorks::Bershelf.berkshelf_binary} #{options}"
end
