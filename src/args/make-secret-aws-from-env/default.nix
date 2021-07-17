{ makeTemplate
, ...
}:
{ accessKeyId
, defaultRegion
, name
, secretAccessKey
, sessionToken
}:
makeTemplate {
  replace = {
    __argAccessKeyId__ = accessKeyId;
    __argDefaultRegion__ = defaultRegion;
    __argSecretAcessKey__ = secretAccessKey;
    __argSessionToken__ = sessionToken;
  };
  name = "make-secret-aws-from-env-for-${name}";
  template = ./template.sh;
}
