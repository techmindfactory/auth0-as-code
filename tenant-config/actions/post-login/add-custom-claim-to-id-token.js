exports.onExecutePostLogin = async (event, api) => {

  let namespace = event.secrets.NAMESPACE || '';
  if (namespace && !namespace.endsWith(':')) {
    namespace += ':';
  }
  api.idToken.setCustomClaim(`${namespace}custom_claim`, 'custom claim value');
};