# Guide voice script for the meditation sessions (English)

The English version of `docs/meditation_recording_script.md`: the same 25 clips in 4 sessions, with the same file names. The tool reads the bold file-name line and the line of text after it, so keep this layout.

To generate the voice (on the developer's computer, never in the app):

1. Copy the Gemini key.
2. Run `dart tool/generate_meditation_voice.dart --voice=Sulafat --lang=en`
3. Run `powershell -NoProfile -ExecutionPolicy Bypass -File tool/wav_to_m4a.ps1 -InputDir build/meditation_voice/wav/en -OutputDir assets/meditation/voice/en`

The files land in `assets/meditation/voice/en/<session>/`. In English, a guided session shows only once all of its English clips are there; until then English users see the silent timer, gamma listening and the active session (bells and on-screen text).

The texts speak in "we" ("Let's breathe", "we notice") on purpose: they address everyone the same way.

---

## 1. Calm breathing (`calm_breathing`)

**breathing_01.m4a**
Welcome. Let's sit comfortably, with the back straight but not stiff. Let's let the shoulders drop a little, and close the eyes if that feels comfortable.

**breathing_02.m4a**
Let's notice the body as it is right now: the feet on the floor, the weight of the hands, and the chest moving with each breath. There is nothing we need to change.

**breathing_03.m4a**
Now let's breathe slowly: in through the nose while we count to four, then a longer breath out while we count to six. We'll repeat this gently, at our own pace.

**breathing_04.m4a**
If the mind wanders to a thought, that's fine. We just notice it, then gently come back to the count: four in, and six out.

**breathing_05.m4a**
Let's let go of the counting now, and let the breath find its natural rhythm. We simply notice it coming in and going out.

**breathing_06.m4a**
We're nearly at the end. Let's move the fingers a little, and slowly open the eyes when we're ready.

## 2. Body scan (`body_scan`)

**body_scan_01.m4a**
Let's lie down or sit comfortably, and close the eyes. We'll move our attention slowly through the body, one part at a time, without trying to change anything.

**body_scan_02.m4a**
Let's start with the feet: the toes, the soles, and where they touch the floor. Then we move our attention up to the legs, the knees and the thighs.

**body_scan_03.m4a**
Now we move to the belly and the chest. We notice them moving with the breath, then the back, from the lower back up to the shoulders.

**body_scan_04.m4a**
Let's bring our attention to the hands: the fingers, the palms, then the arms up to the shoulders. We notice warmth, coolness, or whatever sensation is there.

**body_scan_05.m4a**
We reach the neck and the face: the jaw, the lips, around the eyes, and the forehead. Let's let any tension soften a little, if it can.

**body_scan_06.m4a**
Now let's feel the whole body together, from the feet to the top of the head, breathing calmly.

**body_scan_07.m4a**
We're nearly at the end. Let's take a slightly deeper breath, move the hands and feet, then slowly open the eyes.

## 3. Present moment (`present_moment`)

**present_moment_01.m4a**
Let's sit quietly and close the eyes. These few minutes have no goal other than being here, in this moment.

**present_moment_02.m4a**
Let's listen to the sounds around us, near and far. We don't name them or judge them; we just hear them come and go.

**present_moment_03.m4a**
We move our attention to the body: the feeling of sitting, the warmth of the hands, the movement of the breath. All of it is happening now.

**present_moment_04.m4a**
When a thought passes, let's see it like a cloud in the sky. We notice it, let it drift on, and come back to the moment.

**present_moment_05.m4a**
Let's keep our attention open to everything that is happening: the sounds, the body, the breath. There is nothing we need to do.

**present_moment_06.m4a**
We're nearly at the end. Let's take a moment to appreciate this quiet time, then slowly open the eyes.

## 4. Move, then be still (`move_and_still`)

**move_and_still_01.m4a**
Let's stand in a safe, roomy space. We begin with calm breathing and a gentle stretch of the arms and neck. Every movement is gentle, and we stop at any pain or dizziness.

**move_and_still_02.m4a**
Now let's walk on the spot at a steady pace, letting the arms swing with the steps. We notice the feet as they touch the floor.

**move_and_still_03.m4a**
Let's let the body move as it wants: the shoulders, the arms, the hips. There is no right or wrong movement, just gentle, free movement.

**move_and_still_04.m4a**
Let's stop and sit down. We let the body settle, and notice the pulse and the breath returning to calm. There is nothing to do now but sit.

**move_and_still_05.m4a**
Let's lie on our back if that's comfortable. We let the weight of the body rest on the floor, and relax.

**move_and_still_06.m4a**
We're nearly at the end. Let's slowly move the fingers, then roll onto one side, and get up when we're ready.
