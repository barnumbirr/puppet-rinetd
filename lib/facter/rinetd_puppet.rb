require 'puppet'

Facter.add(:rinetd_version) do
    setcode do
        osfamily = Facter.value('osfamily')
        case osfamily
        when 'Debian'
            command = '/usr/bin/dpkg-query -f \'${Status}\t${Version}\n\' -W rinetd > /dev/null'
            version = Facter::Util::Resolution.exec(command)
            if version =~ %r{.*[install|hold] ok installed;([^;]+);.*}
                Regexp.last_match(1)
            end
        end
    end
end
