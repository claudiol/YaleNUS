all: CloudFlare_gem

CloudFlare_gem:
	gem build spec/CloudFlare.gemspec
	cp CloudFlareDNS-*.gem dist/

install:
	gem install --local dist/CloudFlareDNS-0.1.gem

install-0.2:
	gem install --local dist/CloudFlareDNS-0.2.gem

uninstall:
	gem uninstall CloudFlareDNS

uninstall-0.2:
	gem uninstall CloudFlareDNS -v 0.2
