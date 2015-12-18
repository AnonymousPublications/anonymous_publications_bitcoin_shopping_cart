# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :address do
    sequence(:code_name) {|n| "My House #{n}"}
    
    first_name "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQf/UTM9RsZfkWBG3PzkHzm6GtCBmjXAwbHeSg00rKIe
Mdikzxnm464wG1sM0WDJeQCVQGzGIAkxfvOPU4rnfhq6x/NJpI7WuC4X1uJw
iyxiZnpT/A2PEYdlWbUZQWeeadEgAMdI+yiPJ/SHbQrmWDwLEhpKtwCqjMYi
htJt1W1l+lhAMdGvXh6nIVyQWiqm9+pQrEvewWIAKsxcFk2OGKSfMRRtivWl
ECNCI8z8h0WdIythAVHTJ8CzmEszYuMWRG7LUMhUs3IHNAtCWkoRojISY1/4
KqSqQlhpMwJmYGebPhGiAarpmjtltZA/Dy7ERFfctoLxjE7BkRK7HXnq13XW
4qQk0lyBxx/TadYmlCzDu/B6riOUsbCHJQiwQPpv9+D/CPdK9NWI
=Awa8
-----END PGP MESSAGE-----
"
    last_name "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQf+O6lcxOYNW9a4E46TUfcYm4dSoUeEMXKjdk9RmWvj
o49h2EOWbjR+LoyAYFah9GF8ydBwkrI47dyeokZDJq9lnHQrZdO3BEPzEfd3
xZ7bPAH7kVennN4kkon/uh5cnwQdFcIQufkUWPePIOTM37GVEMwiUWSAk6Tv
sd/hC11UraLgJV/iQ1PKYrQ1k9JFab4qYMNg3vdJCS2i5EmVUldlhxhw2odq
U0e03FM0zjA6oe7/zoci7tYRsvMbDIr7gnNk75s4xKHmA73879uiEgCUXisd
EJtAiCoAi357VJvIGM9p/rLAzBiL3Q8K3LWKWVzjvPp5tIIQZMAF50FF/f9u
A6Qjh6R1leS5aGd6NwEzd6udN4hM+ORUDMUrKNgjGcFhzwFnTrE=
=bbtQ
-----END PGP MESSAGE-----
"
    # sequence(:address1) { "#{rand(100..4000)} Possum Street" }
    address1 "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQgAkkLLYWOzmHDrknH9NWLjTz7cmMN6Da7Oqz57WFQS
3vdFb/72BrdpHnzZRmZNIWBH4Vj7sUcKv0X2Q+WL45qQSELEdOawpgGVvS9A
XrqzAJxbTBKTpyqszqfD/Q8pTMnCIXo0S1zJERBpqLvxQF2rO+sytMn6x9xZ
2ZFKWtpSfcYxR89itnCK3tCBNHH9hJG+ej/oFsXwJgddVuSnRRSPPW6Ea/W2
9G4xuOVnDwpfOLGj7wfP6+AlMuJCGTN6Urd18eGyFiYP+WaPvk51yS4jkzOi
kqRbRLTIvsEiK2KcVyEd6F/NxqTLD7Nw5ADxHyVZzOiNPJKTmwf7diaP8mdm
yqQzC8c5mfPzWhop3DYJXzL2Y4Mgk7qxR08RKIewTR/SWLtlRnFOwT+itBQN
N4nD1x19T0Wp
=dsyQ
-----END PGP MESSAGE-----
"
    sequence(:address2) { rand(1..2).to_s == 1.to_s ? "" : "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQf6AloPtxXYB+OGv+MnFgQofqs6CEMbKoSf45c+hk6c
ZMpqr9/R/ZK6I7Nbla/FCbKmAtttZ0T6I1GAS/6ivFDJ8J7Y7bhag2tueP86
tMfyTL6j6VQGOEu7AoMrx58vk76bC2DYG8BAw42y6lHifz8X9IJAzrccyjT4
HzYmUmoM2sma3qHuN1PZp24qZJqHEOGr8XhpTzaDXuIp00P3+X0NVoLzaZUS
cgxObRImRzHyRSzSHKRnnbTKHg7SKn43J2lpkJV07bqP8HLNTGYG1YzUigjp
PydGX0l1sLjo4I3KTmBetjs5s4sJTH3QqqYq/Dfqfch5/MqE92LrNlxzCtgc
cKQwpTllOo0smnSBLrTnixgEy0mfhUlmVjasEoG9DxD0yinJR+9TeCeskPQk
KdXI8L/O
=Mx2r
-----END PGP MESSAGE-----
" }
    
    #sequence(:apt) { |n| (rand(1..2).to_s == 1.to_s) ? "" : "#{rand(100..2000)}" }
    sequence(:apt) { |n| (rand(1..2).to_s == 1.to_s) ? "" : "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQf/QWtqnGOuYOQqhdv9rot0N8altMdgso71Deub2YqH
yVSrrLhzpvT6mPmNJXHOuS0AtamnNjeMbiJRmkf3m6l56BMYlz904GIbG3Zr
zzJcr8A+N30afhMO/kmZZfK5mjLfKHiyPA71HN5Kd3J8N9aWYwj9HDm3tCSB
dsOvcZ5QXkXwzIj+jtOV1201PvwMyShmTgZqCM7c0OwR/sFKBOhx33tcZKWx
W+k0jbfZJb0RUv95jPuQIeS180O5BRWSUC2tOXaCkgT9u6pC41sRjTZnuH+3
v/DIhV7uyf46f00sCcwpxPedtrchydh+Daww7sPpdQpRKWtk19a+iIIo8Rvt
7KQkA0Y5WuvhTQbdfq8deJzUwqUKJtGVGPcps1PMeIMe6ZTLi0ru
=Gmsg
-----END PGP MESSAGE-----" }


    
    # sequence(:zip) { "#{rand(10000..99999)}" }
    zip "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQgAqyLtfr8yy9aRSNCKy9UTNVhVFFs1ABozP2QUUKVJ
fA/oUeAntTmeFz1Ga7HC1g8iyefE1G/Y2PEaHCSj1JFqczOJS13XgRYO45AK
d9dTLLjl+qElVx78M06mIoXUaeSuaex0X/3qNXauCIeGJpaBf9xMLMlYbxH8
zW3Q1j15VnQz6MFuwoYNXfABc2ekLve076UvUCxbn0G598VmCHHCD28u+Oec
suuxebOcjQWbFNsLoGTpKS+OecilkQ98H1cPkLD7qZHluGWP+0WCOCkg1Ttq
vW+ibdmGW30fq/1EKprJchayANgGdMd/ynbduG0Nn0pGYUk+y5WBucMDINGS
ZKQlHHtkqVBbH14dmx81aGg2gblp6PVaa/fmFw/2FP385ARJ1mRT3w==
=PlFx
-----END PGP MESSAGE-----
"
    
    city "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQgAqPKhl8LbI8Fs+zasPS3a61CWCS8Aus7UgR8Bf3Eu
4UBPOA7B3U4YQXhMoxMYGl/JN0C6IctjkP6PwyKXvNTgpKG1WKuki8/hKKZg
jPLhiDwZeFggzCTqC0GxublCrQOPZjHNUufShCY5D1g/iTKTO3VCuilUDyBj
t3ExgO8k/SgdfbzzrKNe3TktJTOFMOenwr0QQg51B3XrBLih5/ssHWVnrs06
mBlC6jucHY/tuPIAiQj7xJBpncUHJZbqbvkm0xsb8QFFzSoNyCV+3rekpil5
Ylbb9i3Vtr7BIwEowHvqjKaubEy58bxk7F+P5XrLj+yabV9vzUH1xeqFkEwY
3KQq1wOGUHMqR9hmZZfkT70jIo3/+7Wxd8g+RZnH6Sh0jQ6E8i4wTtVgjoCV

=ZHnk
-----END PGP MESSAGE-----
"
    state "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQgAwSy1/X1hRxDkEgX0WTe8EWKCyacxW2J4jvv5/kDM
ZBpOLi78KCCVokrp2hmdkTzM0aJQl45/dkImVOYOpXb9ulnCJXbmpyF6398d
vbGTvjtLXQSaJ41LbCGxu32L1bCQsrBUIORqqL/+C9gdqrMmYItWDXwN2do5
WfVhJShOJEWULSUrhYOC40BuRLKNrv2ruk48bh7Mdn7DQbaBa0jT4iV6flK7
mFvZfAULPOM40UBJ9aCF/GQGBR7lPM3SiaUHfi3rWQihjpUEmHE1l/ui7FWw
+FiaKvKWhvECAIo5iV9V/sUPGj3Zw5JEDFX9J4GS6zry2G9/sU1Ka7nOQx3F
OqQnazqWUIMO9WCMZRV/6gnw7rbOr897ikGXvOdoMY4scVb8dz8bbLT9
=s04T
-----END PGP MESSAGE-----
"
    country "-----BEGIN PGP MESSAGE-----
Version: haneWIN JavascriptPG v2.0

hQEMAxi+vIcfDgArAQgArZZDnWPNSpRwVLfzAuhcOXN0CpX8X70ZeN7pUkUS
Qomf5LpvQ+31dVgCdOpkcf/NgL5fnr7CaJLQ7ovC3f9tz+oxirfRT/SueGL5
hDqQIPE23y0UPoLeNBh8krzhz72o9fQAa3fHG50KCgJpizyUHXaOxo8i8+eA
kzcGTaL12jeTrDSxoy8xGj/xZyS/m1HbcJ7ZdVSChZt72xe/Cj4epgC1SD4b
vm7Ki90EOcY8NylRBeR8/yFKsY3YSE+kF7snD94N2M2O9or+wgT61iXZMYf0
tKeK1woU4C+SnBIo+H+Aa6X4s3OGiFH0GyTxfr+C0r4FzSTO1LcioIq5m6GS
WqQiVhyzg6XScDqB3Je7CGEEjA6oFzOmQmn3Rsa2ZnYNHaqP6g==
=RvKD
-----END PGP MESSAGE-----
"

    after(:build) do |address|
      address.set_encryption_pair
    end

  end
  
  
  
end
