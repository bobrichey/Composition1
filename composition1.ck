// Untitled
// Bob Richey
// December 9th, 2013

// array of modalbars with reverb and panning
Math.random2(6, 16) => int modalVoices;
int ModalVoice[modalVoices];
ModalBar modal[modalVoices];
JCRev modalRev[modalVoices];
Pan2 modalPan[modalVoices];

// sound chain for modalbar
for (int i; i < modalVoices; i++)
{
    modal[i] => modalRev[i] => modalPan[i] => dac;
}

// array of sndbufs with reverb and panning
Math.random2(6, 16) => int drumVoices;
int DrumVoice[drumVoices];
SndBuf drum[drumVoices];
JCRev drumRev[drumVoices];
Pan2 drumPan[drumVoices];

// sound chain for sndbuff
for (int i; i < drumVoices; i++)
{
    drum[i] => drumRev[i] => drumPan[i] => dac;
}

// array of samples for sndbuf
[me.dir() + "/audio/hihat_01.wav",
me.dir() + "/audio/hihat_04.wav",
me.dir() + "/audio/kick_01.wav",
me.dir() + "/audio/kick_03.wav",
me.dir() + "/audio/snare_01.wav",
me.dir() + "/audio/snare_03.wav",
me.dir() + "/audio/click_01.wav",
me.dir() + "/audio/clap_01.wav",
me.dir() + "/audio/cowbell_01.wav"
] @=> string samples[];

// array of pitches for modalbar (A major pentatonic)
[57, 59, 61, 64, 66, 
 69, 71, 73, 76, 78,
 81, 83, 85, 88, 90, 93] @=> int scale[];
 
// function that plays a modalbar; sets the gain, reverb gain, reverb mix, pan, preset, frequency, and duration of modalbar
// skeleton function provided by Dr. Van Stiefel, West Chester University of Pennsylvania
fun void playModal(float gain, float revGain, float revMix, float pan, int preset, int freq, dur ring)
{                                                                                  // "1" or "2", selects scale or random frequencies
    getModalVoice() => int which;
    if (which > -1)
    {
        gain => modal[which].gain;
        revGain => modalRev[which].gain;
        revMix => modalRev[which].mix;
        pan => modalPan[which].pan;
        preset => modal[which].preset; // 0-8 (number of available presets)
        if(freq == 1) {Math.random2f(220, 1760) => modal[which].freq;} // covers same range of frequences as "scale" array
        if(freq == 2) {Std.mtof(scale[Math.random2(0, scale.cap()-1)]) => modal[which].freq;}
        1 => modal[which].noteOn;
        ring => now;
        0 => ModalVoice[which];      
    }
}

// function decides which modalbar in the array will be played when "playModal" is called
// skeleton function provided by Dr. Van Stiefel, West Chester University of Pennsylvania
fun int getModalVoice()
{
    for (int i; i < modalVoices; i++)
    { 
        if (ModalVoice[i] == 0)
        {            
            1 => ModalVoice[i];
            return i;
        }
    }
    return -1;
}

// function that plays a sndbuf; sets the gain, reverb gain, reverb mix, pan, sample, position, playback rate, and duration of sndbuf
fun void playDrum(float gain, float revGain, float revMix, float pan, int sample, int position, float rate, dur ring)
{                                                                                 // "1", "2", or "3", sets position to 0, random, or end

    getDrumVoice() => int which;
    if (which > -1)
    {
        gain => drum[which].gain;
        revGain => drumRev[which].gain;
        revMix => drumRev[which].mix;
        pan => drumPan[which].pan;
        sample => int i;
        samples[i] => drum[which].read;
        drum[which].samples() => int end;
        if(position == 1) {0 => drum[which].pos;}
        if(position == 2) {Math.random2(0, end) => drum[which].pos;}
        if(position == 3) {end => drum[which].pos;}
        rate => drum[which].rate;
        ring => now;
        0 => DrumVoice[which];      
    }
}

// function decides which sndbuf in the array will be played when "playDrum" is called
fun int getDrumVoice()
{
    for (int i; i < drumVoices; i++)
    { 
        if (DrumVoice[i] == 0)
        {            
            1 => DrumVoice[i];
            return i;
        }
    }
    return -1;
}


// MAIN PROGRAM


// sets modalbar preset for first two loops
Math.random2(0, 8) => int preset;

// sets duration of opening pitches
Math.random2(2000, 4000)::ms => dur d;

// modalbar enters
for(0 => int i; i < 15; i++)
{
    spork ~ playModal(Math.random2f(0.1, 0.3), 0.5, 0.7, Math.random2f(-0.5, 0.5), preset, 2, 50::ms);
    d => now;
}

// sets pitch material to pentatonic scale or random frequencies, used before most loops containing modalbar
Math.random2(1, 2) => int pitches;

d/2 => d;

// drums enter, played backwards; number of samples used increases over the first few loops
for(0 => int i; i < 20; i++)
{
    spork ~ playModal(Math.random2f(0.1, 0.3), 0.5, 0.7, Math.random2f(-0.5, 0.5), preset, 2, 50::ms);
    spork ~ playDrum(Math.random2f(0.1, 0.2), 0.3, 0.3, Math.random2f(-0.5, 0.5), Math.random2(0, 4), 3, -1, 50::ms);
    d => now;
}

// modal bar drops out
for(0 => int i; i < 5; i++)
{
    spork ~ playDrum(Math.random2f(0.2, 0.4), 0.3, 0.3, Math.random2f(-0.5, 0.5), Math.random2(0, 5), 3, -1, 50::ms);
    d => now;
}

// drums play forwards and backwards at variable rates, new voices are introduced faster
for(0 => int i; i < 150; i++)
{
    spork ~ playDrum(Math.random2f(0.3, 0.5), 0.3, 0.3, Math.random2f(-0.5, 0.5), Math.random2(0, 6), 2, Math.random2f(-2, 2), Math.random2(100, 500)::ms);
    200::ms => now;
}

Math.random2(1, 2) => pitches;

// modalbar enters, using a limited number of presets; number of samples used increases over the first few loops
for(0 => int i; i < 150; i++)
{
    spork ~ playModal(Math.random2f(0.3, 0.5), 0.4, 0.5, Math.random2f(-0.5, 0.5), Math.random2(0, 4), pitches, Math.random2(1000, 5000)::ms);
    spork ~ playDrum(Math.random2f(0.2, 0.4), 0.4, 0.3, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 2, Math.random2f(-2, 2), Math.random2(100, 500)::ms);
    150::ms => now;
}

Math.random2(1, 2) => pitches;

// drums drop out
for(0 => int i; i < 50; i++)
{
    spork ~ playModal(Math.random2f(0.3, 0.5), 0.4, 0.5, Math.random2f(-0.5, 0.5), Math.random2(0, 5), pitches, Math.random2(1000, 5000)::ms);
    150::ms => now;
}

Math.random2(1, 2) => pitches;

// modalbar voices are introduced faster
for(0 => int i; i < 100; i++)
{
    spork ~ playModal(Math.random2f(0.3, 0.5), 0.5, 0.5, Math.random2f(-0.5, 0.5), Math.random2(0, 6), pitches, Math.random2(1000, 3000)::ms);
    100::ms => now;
}

Math.random2(1, 2) => pitches;

// faster still...
for(0 => int i; i < 150; i++)
{
    spork ~ playModal(Math.random2f(0.4, 0.6), 0.5, 0.5, Math.random2f(-0.5, 0.5), Math.random2(0, 8), pitches, Math.random2(600, 1800)::ms);
    75::ms => now;
}

Math.random2(1, 2) => pitches;

// drums enter, played forwards at a normal rate
for(0 => int i; i < 250; i++)
{
    spork ~ playModal(Math.random2f(0.3, 0.5), 0.5, 0.5, Math.random2f(-0.5, 0.5), Math.random2(0, 8), pitches, Math.random2(600, 1800)::ms);
    spork ~ playDrum(Math.random2f(0.2, 0.4), 0.4, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 1, 1, Math.random2(1000, 5000)::ms);
    75::ms => now;
}

Math.random2(1, 2) => pitches;

// modalbar gets softer, drums get louder
for(0 => int i; i < 250; i++)
{
    spork ~ playModal(Math.random2f(0.2, 0.4), 0.4, 0.4, Math.random2f(-0.5, 0.5), Math.random2(0, 8), pitches, Math.random2(1200, 2800)::ms);
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 1, 1, Math.random2(1000, 5000)::ms);
    75::ms => now;
}

// modalbar drops out
for(0 => int i; i < 50; i++)
{
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 1, 1, Math.random2(1000, 5000)::ms);
    75::ms => now;
}

// drums are played forwards and backwards at variable rates, range of rate variability is wider than before
for(0 => int i; i < 150; i++)
{
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 2, Math.random2f(-5, 5), Math.random2(700, 2500)::ms);
    75::ms => now;
}

// drum voices are introduced faster
for(0 => int i; i < 150; i++)
{
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 2, Math.random2f(-5, 5), Math.random2(100, 400)::ms);
    50::ms => now;
}

// rate of drum playback is slowed
for(0 => int i; i < 500; i++)
{
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 2, Math.random2f(-0.2, 0.2), Math.random2(1000, 5000)::ms);
    50::ms => now;
}

// modalbar enters, quietly, with a very short duration; preset and pitch are specified
for(0 => int i; i < 300; i++)
{
    spork ~ playModal(Math.random2f(0.02, 0.07), 0.3, 0.2, Math.random2f(-0.5, 0.5), 0, 2, 50::ms);
    spork ~ playDrum(Math.random2f(0.4, 0.6), 0.6, 0.2, Math.random2f(-0.5, 0.5), Math.random2(0, 8), 2, Math.random2f(-0.2, 0.2), Math.random2(1000, 5000)::ms);
    50::ms => now;
}

// drums drop out
for(0 => int i; i < 200; i++)
{
    spork ~ playModal(Math.random2f(0.02, 0.07), 0.3, 0.2, Math.random2f(-0.5, 0.5), 0, 2, 50::ms);
    50::ms => now;
}

// selects a drum sample to use in next loop
Math.random2(0, 8) => int sample;

// drums enter, with a very short duration; sample is played forward with a more tightly controlled rate
for(0 => int i; i < 200; i++)
{
    spork ~ playModal(Math.random2f(0.05, 0.1), 0.3, 0.2, Math.random2f(-0.5, 0.5), 0, 2, 50::ms);
    spork ~ playDrum(Math.random2f(0.1, 0.2), 0.2, 0.2, Math.random2f(-0.5, 0.5), sample, 1, Math.random2f(1, 1.5), 50::ms);
    50::ms => now;
}

// the material from previous loop is repeated five times, with a two second pause between each repeat
for(0 => int i; i < 5; i++)
{
    2::second => now;   
    Math.random2(0, 8) => sample;   
    for(0 => int i; i < Math.random2(15, 50); i++)
    {
        spork ~ playModal(Math.random2f(0.05, 0.1), 0.3, 0.2, Math.random2f(-0.5, 0.5), 0, 2, 50::ms);
        spork ~ playDrum(Math.random2f(0.1, 0.2), 0.2, 0.2, Math.random2f(-0.5, 0.5), sample, 1, Math.random2f(1, 1.5), 50::ms);
        50::ms => now;
    }
}

// first loop of the piece is repeated more quietly, "d" is multiplied by two since it was halved for the second loop
for(0 => int i; i < 15; i++)
{
    spork ~ playModal(Math.random2f(0.1, 0.3), 0.3, 0.4, Math.random2f(-0.5, 0.5), preset, 2, 50::ms);
    d*2 => now;
}

// allows final pitch to release
1::second => now;