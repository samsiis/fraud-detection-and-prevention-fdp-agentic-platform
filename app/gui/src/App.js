import { Amplify } from 'aws-amplify';
import config from './amplifyconfiguration.json';
import { withAuthenticator, Button, Heading } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';

Amplify.configure(config);

function App({ signOut, user }) {
  return (
    <>
      <Heading level={1}>Hello {user.username}</Heading>
      <Button onClick={signOut}>Sign out</Button>
      <h2>Amplify Todos</h2>
    </>
  );
}

export default withAuthenticator(App);
