import { useBackend, useLocalState } from '../../backend';
import { Box, Button, ByondUi, Divider, Icon, LabeledList, NoticeBox, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CharacterTab } from './CharacterTab';
import { GameSettingsTab } from './GameSettingsTab';
import { GeneralTab } from './GeneralTab';
import { SavesTab } from './SavesTab';
import { CharacterPreferencesData, CharacterPreferencesProfile, CharacterPreferencesTabKeys } from './type';

export const CharacterPreferences = (_props: any, context: any) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);
  const [menu, setMenu] = useLocalState(context, 'menu', CharacterPreferencesTabKeys.General);

  return (
    <Window width={600} height={750} title="Character Setup">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <SavesAndProfile />
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={menu === CharacterPreferencesTabKeys.General}
                onClick={() => setMenu(CharacterPreferencesTabKeys.General)}>
                General
              </Tabs.Tab>
              <Tabs.Tab
                selected={menu === CharacterPreferencesTabKeys.Character}
                onClick={() => setMenu(CharacterPreferencesTabKeys.Character)}>
                Appearance
              </Tabs.Tab>
              <Tabs.Tab onClick={() => act('open-occupation-window')}>Occupation</Tabs.Tab>
              <Tabs.Tab onClick={() => act('open-traits-window')}>Traits</Tabs.Tab>
              <Tabs.Tab
                selected={menu === CharacterPreferencesTabKeys.GameSettings}
                onClick={() => setMenu(CharacterPreferencesTabKeys.GameSettings)}>
                Game Settings
              </Tabs.Tab>
              <Tabs.Tab
                selected={menu === CharacterPreferencesTabKeys.Saves}
                onClick={() => setMenu(CharacterPreferencesTabKeys.Saves)}>
                Cloud Saves
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow="1">
            {menu === CharacterPreferencesTabKeys.General || menu === CharacterPreferencesTabKeys.Character ? (
              <Stack fill>
                <Stack.Item grow="1">
                  <Section scrollable fill>
                    {menu === CharacterPreferencesTabKeys.General && <GeneralTab />}
                    {menu === CharacterPreferencesTabKeys.Character && <CharacterTab />}
                  </Section>
                </Stack.Item>
                <Stack.Item ml="5px">
                  <Section fill>
                    <ByondUi
                      params={{
                        id: data.preview,
                        type: 'map',
                      }}
                      style={{
                        width: '64px',
                        height: '128px',
                      }}
                    />
                    <Box textAlign="center" mt="5px">
                      <Button icon="chevron-left" onClick={() => act('rotate-clockwise')} />
                      <Button icon="chevron-right" onClick={() => act('rotate-counter-clockwise')} />
                    </Box>
                  </Section>
                </Stack.Item>
              </Stack>
            ) : (
              <Section scrollable fill>
                {menu === CharacterPreferencesTabKeys.GameSettings && <GameSettingsTab />}
                {menu === CharacterPreferencesTabKeys.Saves && <SavesTab />}
              </Section>
            )}
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Button.Confirm content="Reset All" onClick={() => act('reset')} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SavesAndProfile = (_props: any, context: any) => {
  const { act, data } = useBackend<CharacterPreferencesData>(context);

  const activeProfileIndex = data.profiles.findIndex((p) => p.active);

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          {data.profiles.map((profile, index) => (
            <Stack.Item key={index} ml={index === 0 ? '0' : '5px'} grow="1">
              <Profile profile={profile} index={index} />
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Profile Name"
              buttons={
                activeProfileIndex > -1 ? (
                  <>
                    <Button onClick={() => act('load', { index: activeProfileIndex + 1 })}>Reload</Button>
                    {' - '}
                    <Button onClick={() => act('save', { index: activeProfileIndex + 1 })}>Save</Button>
                  </>
                ) : null
              }>
              <Button onClick={() => act('update-profileName')}>
                {data.profileName ? data.profileName : <Box italic>None</Box>}
              </Button>
            </LabeledList.Item>
          </LabeledList>
          {!!data.profileModified && (
            <>
              <Divider />
              <NoticeBox danger>
                <Stack>
                  <Stack.Item align="center">
                    <Icon name="exclamation-triangle" />
                  </Stack.Item>
                  <Stack.Item>
                    <Box>You may have unsaved changes!</Box>
                    <Box>Any unsaved changes will take effect for this round only.</Box>
                  </Stack.Item>
                </Stack>
              </NoticeBox>
            </>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type ProfileProps = {
  index: number,
  profile: CharacterPreferencesProfile
}

const Profile = (props: ProfileProps, context: any) => {
  const {
    index,
    profile,
  } = props;
  const { act } = useBackend<CharacterPreferencesData>(context);

  return (
    <Section
      title={`Profile ${index + 1}`}
      textAlign="center"
      backgroundColor={profile.active ? 'rgba(0, 0, 0, 0.10)' : null}>
      <Box mb="5px">
        {profile.name ? (
          <Box>{profile.name}</Box>
        ) : (
          <Box italic color="label">
            Empty
          </Box>
        )}
      </Box>
      <Button disabled={!profile.name} onClick={() => act('load', { index: index + 1 })}>
        Load
      </Button>
      {' - '}
      <Button onClick={() => act('save', { index: index + 1 })}>Save</Button>
    </Section>
  );
};