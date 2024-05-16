import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

export const SecretsMenu = (props, context) => {
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <DebugButtons />
      </Window.Content>
    </Window>
  );
};

const DebugButtons = (properties, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section>
      <Box>
        <Icon name="bug-slash" />
        Debug Menu
      </Box>
    </Section>
  );
};
