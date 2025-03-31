# Generated by Django 5.1.4 on 2025-03-31 11:43

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_services_request_count'),
    ]

    operations = [
        migrations.CreateModel(
            name='Availability',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField()),
                ('start_time', models.TimeField()),
                ('end_time', models.TimeField()),
                ('provider', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='availabilities', to='api.provider')),
            ],
            options={
                'unique_together': {('provider', 'date', 'start_time', 'end_time')},
            },
        ),
    ]
