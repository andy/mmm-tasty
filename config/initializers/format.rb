module Format
  DOMAIN    = /^([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+((a[cdefgilmnoqrstuwxz]|aero|arpa)|(b[abdefghijmnorstvwyz]|biz)|(c[acdfghiklmnorsuvxyz]|cat|com|coop)|d[ejkmoz]|(e[ceghrstu]|edu)|f[ijkmor]|(g[abdefghilmnpqrstuwy]|gov)|h[kmnrtu]|(i[delmnoqrst]|info|int)|(j[emop]|jobs)|k[eghimnprwyz]|l[abcikrstuvy]|(m[acdghklmnopqrstuvwxyz]|mil|mobi|museum)|(n[acefgilopruz]|name|net)|(om|org)|(p[aefghklmnrstwy]|pro)|qa|r[eouw]|s[abcdeghijklmnortvyz]|(t[cdfghjklmnoprtvwz]|travel)|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw])$/i unless const_defined?(:DOMAIN)
  LINK      = /^(http|https|ftp):\/\/([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+/i
  HTTP_LINK = /^(http|https):\/\/([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+/i
  STRING    = /^[a-z0-9-]+$/i
  EMAIL     = /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i
end