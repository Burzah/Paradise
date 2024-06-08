import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';

export const OrionTrail = (props, context) => {
  const { act, data } = useBackend(context);
  const { engine, hull, electronics, food, fuel, playing, turns, gameOver } =
    data;
  return (
    <Window width={625} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill>
              <Stack.Item fontSize={3} mt={12} mb={3} textAlign="center">
                THE ORION TRAIL
              </Stack.Item>
              <Stack.Item textAlign="center">
                <Icon name="person-hiking" size={10} mb={5} />
              </Stack.Item>
              <Stack.Item textAlign="center">PLACEHOLDER</Stack.Item>
              <Stack.Item mt={10}>
                <Button
                  textAlign="center"
                  fluid
                  icon="play"
                  color="green"
                  content="Play"
                  onClick={() => act('')}
                />
                <Button
                  textAlign="center"
                  fluid
                  icon="info"
                  color="blue"
                  content="Guide"
                  onClick={() => act('')}
                />
              </Stack.Item>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
